#!/usr/bin/env python3
"""Arctis Nova Pro Wireless — OLED daemon v3.5 (Barbados).

v3.5 (2026-10-16): fix notification lag. NotifWatch only handled a
dbus-monitor block when the NEXT notification's block started, so
every notification displayed one notification late — and a lone
notification never displayed at all (one sent 2026-10-16 ~09:46
was only flushed by the old daemon's shutdown at 10:07). The pty
reader now uses select() and flushes a block after 0.5s of quiet:
a Notify call's lines arrive in one burst, so quiet = complete.

v3.4 (2026-10-16): no idle release. Shorki asked for the music/stats
pages to keep rotating even when nothing is playing, instead of
handing the screen back to the stock UI after 60s idle (the v3.1-era
behavior). The screen is released to stock only on shutdown.

v3.3 (2026-10-16): self-heal after USB re-enumeration, and at boot.
v3.1 opened the hidraw node exactly once. Any USB disconnect/replug
(or an enumeration shuffle around boot) invalidated that fd, and
the log-and-continue loop then spammed "[Errno 19] No such device"
forever while systemd still showed the service active — the screen
froze after every reconnect/reboot until a manual restart. v3.3
catches ENODEV/EIO/EPIPE/EBADF from the HID fd, drops the dead fd,
waits for the base to (re)appear, reopens it and resumes. Startup
also waits for the base instead of exiting when it is not
enumerated yet, and opens ride out the brief PermissionError while
the udev uaccess ACL lands on a freshly-created hidraw node.

Rotating pages on the base's 128x64 OLED, flipping every 5 seconds:
  1. MUSIC  — album art (MPRIS artUrl, dithered) + track/artist/time + progress
  2. STATS  — Barbados vitals with bar gauges + headset battery line
Desktop notifications (org.freedesktop.Notifications) preempt any page
for ~6 seconds. Screen returns to stock UI (0x95) on shutdown. (No audio capture anywhere — visuals = artwork + gauges,
per Shorki's correction 2026-10-12.)
"""
import os, sys, glob, select, fcntl, time, signal, subprocess, threading, io, urllib.request, socket, struct
import dbus
from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageEnhance

VIDPID = "00001038:000012E0"
HIDIOCSFEATURE_1024 = 0xC4004806
W, H = 128, 64
PAGE_SECS = 10
NOTIF_SECS = 6

# ---------------- HID ----------------
def find_node():
    for path in sorted(glob.glob("/sys/class/hidraw/hidraw*")):
        try:
            uevent = open(os.path.join(path, "device", "uevent")).read()
            desc = open(os.path.join(path, "device", "report_descriptor"), "rb").read()
        except OSError:
            continue
        if VIDPID in uevent and (b"\x06\xc0\xff" in desc or b"\x06\x00\xff" in desc):
            return "/dev/" + os.path.basename(path)
    return None

def try_open(node):
    """Open node, riding out the udev uaccess ACL lag on fresh nodes.

    A re-enumerated hidraw node can exist a moment before logind's
    uaccess ACL grants the session user access; retry PermissionError
    for a few seconds instead of dying on it. Any other OSError (the
    node vanished mid-open) just gives up so the caller rescans.
    """
    for _ in range(6):
        try:
            return Base(node)
        except PermissionError:
            time.sleep(1)
        except OSError:
            return None
    return None


def acquire_base():
    """Return an opened Base on the base's current node, or None."""
    node = find_node()
    if not node:
        return None
    return try_open(node)


class Base:
    def __init__(self, node):
        self.node = node
        self.fd = os.open(node, os.O_RDWR | os.O_NONBLOCK)
        self.bat = None
        self.dock = None
        self.vol = None

    def query(self, cmd):
        os.write(self.fd, bytes([0x06, cmd]) + bytes(62))
        deadline = time.time() + 1.5
        while time.time() < deadline:
            r, _, _ = select.select([self.fd], [], [], 0.3)
            if not r:
                continue
            try:
                d = os.read(self.fd, 64)
            except BlockingIOError:
                continue
            if len(d) >= 2 and d[0] == 0x06 and d[1] == cmd:
                return d
        return None

    def poll_status(self):
        d = self.query(0xB0)
        if d and len(d) >= 8:
            self.bat = round(d[6] / 8 * 100)
            self.dock = round(d[7] / 8 * 100)
        d = self.query(0x20)
        if d and len(d) >= 4:
            raw = d[3]
            if 0 <= raw <= 0x38:
                self.vol = round((0x38 - raw) / 56 * 100)

    def push_frame(self, img):
        px = img.load()
        for split in range(2):
            dst_x = split * 64
            rep = bytearray(1024)
            rep[0] = 0x06; rep[1] = 0x93; rep[2] = dst_x; rep[3] = 0
            rep[4] = 64; rep[5] = 64
            for x in range(64):
                for y in range(64):
                    if px[dst_x + x, y]:
                        ri = x * 64 + y
                        rep[6 + ri // 8] |= (1 << (ri % 8))
            fcntl.ioctl(self.fd, HIDIOCSFEATURE_1024, bytes(rep))

    def release(self):
        try:
            os.write(self.fd, bytes([0x06, 0x95]) + bytes(62))
        except OSError:
            pass

    def close(self):
        try:
            os.close(self.fd)
        except OSError:
            pass

# ---------------- PC stats ----------------
class PCStats:
    def __init__(self):
        self.prev = None
        self.cpu_pct = 0.0
        self.temp = None
        self.ram = None
        self.disk_free = None
        self.pcbat = None
        self.load1 = None
        self._temp_path = self._find_temp()

    def _find_temp(self):
        for z in glob.glob("/sys/class/thermal/thermal_zone*"):
            try:
                if open(os.path.join(z, "type")).read().strip() == "x86_pkg_temp":
                    return os.path.join(z, "temp")
            except OSError:
                pass
        return None

    def sample(self):
        try:
            parts = open("/proc/stat").readline().split()[1:]
            vals = [int(v) for v in parts]
            idle = vals[3] + vals[4]
            total = sum(vals)
            if self.prev:
                pidle, ptotal = self.prev
                dt = total - ptotal
                if dt > 0:
                    raw = 100.0 * (1 - (idle - pidle) / dt)
                    self.cpu_pct = 0.5 * self.cpu_pct + 0.5 * raw
            self.prev = (idle, total)
        except (OSError, ValueError, IndexError):
            pass
        if self._temp_path:
            try:
                self.temp = round(int(open(self._temp_path).read().strip()) / 1000)
            except (OSError, ValueError):
                pass
        try:
            mem = {}
            for line in open("/proc/meminfo").readlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    mem[k.strip()] = v.split()[0]
            total = int(mem["MemTotal"]) / 1048576
            used = total - int(mem["MemAvailable"]) / 1048576
            self.ram = (used, total)
        except (OSError, ValueError, KeyError):
            pass
        try:
            st = os.statvfs("/")
            self.disk_free = round(st.f_bavail * st.f_frsize / 1073741824)
        except OSError:
            pass
        for b in glob.glob("/sys/class/power_supply/BAT*"):
            try:
                pct = int(open(os.path.join(b, "capacity")).read().strip())
                status = open(os.path.join(b, "status")).read().strip()
                self.pcbat = (pct, status)
            except (OSError, ValueError):
                pass
            break
        try:
            self.load1 = float(open("/proc/loadavg").read().split()[0])
        except (OSError, ValueError):
            pass

# ---------------- BeamNG telemetry (OutGauge, UDP) ----------------
OG_STRUCT = struct.Struct("<I4sHBBfffffffIIfff16s16s")  # 92 bytes, +4 if ID appended

class Telemetry:
    """Listens for BeamNG OutGauge packets on 127.0.0.1:4444."""
    def __init__(self, port=4444):
        self.port = port
        self.mph = 0.0
        self.rpm = 0.0
        self.gear = 1  # OutGauge: 0=R, 1=N, 2+=forward gears
        self.throttle = 0.0
        self.brake = 0.0
        self.max_rpm = 7000.0
        self.last_seen = 0.0
        self._announced = False
        self._thread = threading.Thread(target=self._run, daemon=True)

    def start(self):
        self._thread.start()

    def _run(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            sock.bind(("127.0.0.1", self.port))
        except OSError as e:
            print(f"arctis-oled: telemetry bind failed: {e}", flush=True)
            return
        print(f"arctis-oled: telemetry listener on 127.0.0.1:{self.port} (BeamNG OutGauge)", flush=True)
        sock.settimeout(2.0)
        while True:
            try:
                data, _addr = sock.recvfrom(256)
            except socket.timeout:
                continue
            except OSError:
                continue
            if len(data) < OG_STRUCT.size:
                continue
            try:
                f = OG_STRUCT.unpack_from(data)
            except struct.error:
                continue
            # f: 0 time, 1 car, 2 flags, 3 gear, 4 plid, 5 speed m/s, 6 rpm,
            # 7 turbo, 8 engTemp, 9 fuel, 10 oilP, 11 oilT, 12/13 lights,
            # 14 throttle, 15 brake, 16 clutch, 17/18 displays
            self.gear = f[3]
            self.mph = f[5] * 2.23694
            self.rpm = f[6]
            self.throttle = f[14]
            self.brake = f[15]
            if self.rpm > self.max_rpm:
                self.max_rpm = self.rpm * 1.02
            self.last_seen = time.time()
            if not self._announced:
                print("arctis-oled: OutGauge telemetry LIVE", flush=True)
                self._announced = True

    def fresh(self, now):
        return self.last_seen and (now - self.last_seen) < 2.5

    def gear_text(self):
        if self.gear == 0:
            return "R"
        if self.gear == 1:
            return "N"
        return str(self.gear - 1)

# ---------------- Notifications ----------------
class NotifWatch:
    def __init__(self):
        self.current = None  # (app, summary, body, expires_at)
        self._thread = threading.Thread(target=self._run, daemon=True)

    def start(self):
        self._thread.start()

    def _run(self):
        import pty
        announced = False
        while True:
            try:
                master, slave = pty.openpty()
                proc = subprocess.Popen(
                    ["dbus-monitor", "--session", "--monitor",
                     "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"],
                    stdout=slave, stderr=slave, stdin=slave, close_fds=True)
                os.close(slave)
            except OSError as e:
                print(f"arctis-oled: dbus-monitor unavailable: {e}", flush=True)
                time.sleep(5)
                continue
            if not announced:
                print("arctis-oled: notification mirroring on", flush=True)
                announced = True
            block = []
            pending = b""
            last_line_at = 0.0
            try:
                while True:
                    r, _, _ = select.select([master], [], [], 0.25)
                    if master in r:
                        try:
                            chunk = os.read(master, 4096)
                        except OSError:
                            break
                        if not chunk:
                            break
                        pending += chunk
                        while b"\n" in pending:
                            raw, pending = pending.split(b"\n", 1)
                            line = raw.decode(errors="replace").rstrip("\r")
                            last_line_at = time.time()
                            if line.startswith("method call"):
                                self._handle(block)
                                block = [line]
                            else:
                                block.append(line)
                    if block and time.time() - last_line_at >= 0.5:
                        self._handle(block)
                        block = []
            except OSError:
                pass
            finally:
                try:
                    os.close(master)
                except OSError:
                    pass
            self._handle(block)
            try:
                proc.terminate()
            except OSError:
                pass
            time.sleep(3)

    def _handle(self, block):
        if not block or "member=Notify" not in block[0]:
            return
        strings = []
        for line in block:
            s = line.strip()
            if s.startswith('string "') and s.endswith('"'):
                strings.append(s[len('string "'):-1])
        # order: app_name, app_icon, summary, body (uint32/array lines skipped)
        if len(strings) >= 3:
            app = strings[0]
            summary = strings[2]
            body = strings[3] if len(strings) > 3 else ""
            if summary or body:
                self.current = (app, summary, body, time.time() + NOTIF_SECS)
                print(f"arctis-oled: notification from {app}: {summary[:40]}", flush=True)

# ---------------- MPRIS ----------------
def get_player(bus):
    try:
        names = bus.list_names()
    except dbus.DBusException:
        return None
    players = [n for n in names if n.startswith("org.mpris.MediaPlayer2.")]
    best = None
    for name in sorted(players, key=lambda n: (0 if "spotify" in n else 1, n)):
        try:
            obj = bus.get_object(name, "/org/mpris/MediaPlayer2")
            props = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
            status = str(props.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus"))
            meta = props.Get("org.mpris.MediaPlayer2.Player", "Metadata")
            artist = ""
            artists = meta.get("xesam:artist")
            if artists:
                artist = ", ".join(str(a) for a in artists)
            title = str(meta.get("xesam:title", ""))
            length = int(meta.get("mpris:length", 0) or 0)
            art = str(meta.get("mpris:artUrl", "") or "")
            trackid = str(meta.get("mpris:trackid", "") or title)
            pos = 0
            try:
                pos = int(props.Get("org.mpris.MediaPlayer2.Player", "Position"))
            except dbus.DBusException:
                pass
            cand = {"status": status, "artist": artist, "title": title,
                    "length": length, "pos": pos, "art": art, "trackid": trackid}
            if status == "Playing":
                return cand
            if best is None:
                best = cand
        except dbus.DBusException:
            continue
    return best

# ---------------- Album art ----------------
class ArtCache:
    def __init__(self):
        self.cache = {}

    def get(self, player):
        if not player or not player["art"]:
            return None
        key = player["trackid"]
        if key in self.cache:
            return self.cache[key]
        img = None
        try:
            req = urllib.request.Request(player["art"], headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=3) as r:
                data = r.read()
            im = Image.open(io.BytesIO(data)).convert("L")
            im = ImageOps.autocontrast(im)
            im = im.resize((52, 52), Image.LANCZOS)
            im = ImageEnhance.Contrast(im).enhance(0.93)  # ~7% softer, per Shorki
            img = im.convert("1")
        except Exception as e:
            print(f"arctis-oled: art fetch failed: {e}", flush=True)
            img = None
        self.cache[key] = img
        if len(self.cache) > 8:
            self.cache.pop(next(iter(self.cache)))
        return img

# ---------------- Rendering ----------------
FONT_CANDIDATES = (
    "/usr/share/fonts/noto/NotoSans-Bold.ttf",
    "/usr/share/fonts/liberation/LiberationSans-Bold.ttf",
    "/usr/share/fonts/noto/NotoSans-Regular.ttf",
    "/usr/share/fonts/liberation/LiberationSans-Regular.ttf",
    "/usr/share/fonts/Adwaita/AdwaitaSans-Regular.ttf",
    "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/TTF/DejaVuSans.ttf",
)

def load_font(sz):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, sz)
            except OSError:
                continue
    return ImageFont.load_default()

F_TITLE = load_font(13)
F_MED = load_font(11)
F_SMALL = load_font(10)
F_BIG = load_font(30)
F_HUGE = load_font(36)
F_GEAR = load_font(46)
F_SPEED = load_font(50)
F_GEAR_SM = load_font(30)

def marquee(dr, text, font, x, y, width, scroll_px):
    tw = dr.textlength(text, font=font)
    if tw <= width:
        dr.text((x, y), text, font=font, fill=1)
    else:
        cycle = int(tw) + 24
        off = scroll_px % cycle
        dr.text((x - off, y), text, font=font, fill=1)
        dr.text((x - off + cycle, y), text, font=font, fill=1)

def wrap_text(dr, text, font, width, max_lines):
    words = text.replace("\n", " ").split()
    lines = []
    cur = ""
    for w_ in words:
        trial = (cur + " " + w_).strip()
        if dr.textlength(trial, font=font) <= width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w_
        if len(lines) == max_lines:
            return lines
    if cur and len(lines) < max_lines:
        lines.append(cur)
    return lines

def render_music(base, player, art, scroll_px):
    img = Image.new("1", (W, H), 0)
    dr = ImageDraw.Draw(img)
    if art is not None:
        img.paste(art, (0, 0))
    else:
        dr.rectangle([0, 0, 51, 51], outline=1)
        dr.text((12, 10), "♪", font=F_BIG, fill=1)
    x = 56
    width = W - x - 1
    if player:
        title = player["title"] or "(unknown)"
        artist = player["artist"]
        marquee(dr, title, F_MED, x, 1, width, scroll_px)
        if artist:
            marquee(dr, artist, F_SMALL, x, 15, width, scroll_px)
        length, pos = player["length"], player["pos"]
        if length > 0:
            cur = f"{pos // 1_000_000 // 60}:{pos // 1_000_000 % 60:02d}"
            tot = f"{length // 1_000_000 // 60}:{length // 1_000_000 % 60:02d}"
            dr.text((x, 29), f"{cur}/{tot}", font=F_SMALL, fill=1)
            frac = min(1.0, max(0.0, pos / length))
            dr.rectangle([0, 58, W - 1, 62], outline=1)
            if frac > 0.01:
                dr.rectangle([1, 59, 1 + int((W - 2) * frac), 61], fill=1)
        if player["status"] != "Playing":
            dr.text((x, 42), "PAUSED", font=F_SMALL, fill=1)
    else:
        dr.text((x, 4), "nothing", font=F_MED, fill=1)
        dr.text((x, 17), "playing", font=F_MED, fill=1)
    parts = []
    if base.bat is not None:
        parts.append(f"B{base.bat}%")
    if base.vol is not None:
        parts.append(f"V{base.vol}%")
    if parts:
        dr.text((x, 42) if not player or player["status"] == "Playing" else (x, 42), "", font=F_SMALL, fill=1)
        if player and player["status"] == "Playing":
            pass
    return img

def render_stats(base, pc):
    img = Image.new("1", (W, H), 0)
    dr = ImageDraw.Draw(img)
    dr.text((1, 0), "BARBADOS", font=F_TITLE, fill=1)
    if pc.load1 is not None:
        dr.text((92, 2), f"L {pc.load1:.2f}", font=F_SMALL, fill=1)
    dr.line([(0, 16), (W - 1, 16)], fill=1)
    def bar(x, y, w_, frac):
        dr.rectangle([x, y, x + w_, y + 6], outline=1)
        if frac > 0.01:
            dr.rectangle([x + 1, y + 1, x + 1 + int((w_ - 1) * min(1.0, frac)), y + 5], fill=1)
    y = 19
    dr.text((1, y), "CPU", font=F_SMALL, fill=1)
    bar(30, y + 1, 52, pc.cpu_pct / 100)
    temp = f"{pc.cpu_pct:.0f}% {pc.temp}C" if pc.temp is not None else f"{pc.cpu_pct:.0f}%"
    dr.text((86, y), temp, font=F_SMALL, fill=1)
    y += 10
    dr.text((1, y), "RAM", font=F_SMALL, fill=1)
    if pc.ram:
        bar(30, y + 1, 52, pc.ram[0] / pc.ram[1])
        dr.text((86, y), f"{pc.ram[0]:.1f}G", font=F_SMALL, fill=1)
    y += 10
    dr.text((1, y), "DSK", font=F_SMALL, fill=1)
    if pc.disk_free is not None:
        dr.text((30, y), f"{pc.disk_free}G FREE", font=F_SMALL, fill=1)
    if pc.pcbat:
        dr.text((86, y), f"B{pc.pcbat[0]}%", font=F_SMALL, fill=1)
    y += 10
    parts = []
    if base.bat is not None:
        parts.append(f"HS {base.bat}%")
    if base.dock is not None:
        parts.append(f"DK {base.dock}%")
    if base.vol is not None:
        parts.append(f"V {base.vol}%")
    dr.text((1, y), "  ".join(parts), font=F_SMALL, fill=1)
    return img

def render_drive(tel):
    img = Image.new("1", (W, H), 0)
    dr = ImageDraw.Draw(img)
    # Speed: the star of the page — 50px digits, left
    dr.text((0, -3), f"{int(round(tel.mph))}", font=F_SPEED, fill=1)
    # Gear: smaller now, top-right corner
    dr.text((104, 0), tel.gear_text(), font=F_GEAR_SM, fill=1)
    dr.text((103, 33), "MPH", font=F_SMALL, fill=1)
    # RPM numeric, bottom-left above the tach bar
    dr.text((2, 43), f"RPM {int(tel.rpm)}", font=F_SMALL, fill=1)
    # Tach bar across the bottom, redline tick at 85% of scale
    frac = min(1.0, tel.rpm / tel.max_rpm) if tel.max_rpm > 0 else 0.0
    dr.rectangle([0, 54, W - 1, 62], outline=1)
    if frac > 0.01:
        dr.rectangle([1, 55, 1 + int((W - 2) * frac), 61], fill=1)
    tick_x = int((W - 1) * 0.85)
    dr.line([(tick_x, 51), (tick_x, 53)], fill=1)
    return img

def render_notif(n):
    app, summary, body, _exp = n
    img = Image.new("1", (W, H), 0)
    dr = ImageDraw.Draw(img)
    dr.rectangle([0, 0, W - 1, H - 1], outline=1)
    dr.rectangle([1, 1, W - 2, H - 2], outline=1)
    dr.text((5, 3), (app or "Notification")[:18], font=F_SMALL, fill=1)
    dr.line([(4, 15), (W - 5, 15)], fill=1)
    y = 18
    for line in wrap_text(dr, summary, F_MED, W - 10, 2):
        dr.text((5, y), line, font=F_MED, fill=1)
        y += 12
    for line in wrap_text(dr, body, F_SMALL, W - 10, 2):
        dr.text((5, y + 1), line, font=F_SMALL, fill=1)
        y += 11
    return img

# ---------------- Main loop ----------------
def main():
    base = acquire_base()
    if base is None:
        print("arctis-oled: base not found — waiting for it to appear", flush=True)
        while base is None:
            time.sleep(2)
            base = acquire_base()
    node = base.node
    pc = PCStats()
    notifs = NotifWatch()
    notifs.start()
    tel = Telemetry()
    tel.start()
    arts = ArtCache()
    print(f"arctis-oled v3.5: connected to {node}; pages rotate every {PAGE_SECS}s", flush=True)
    bus = dbus.SessionBus()
    state = {"released": True}

    def shutdown(signum, frame):
        base.release()
        base.close()
        sys.exit(0)
    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    def reopen_base():
        """Drop the dead fd, wait for the base, swap in a fresh one.

        The shutdown handler reads the enclosing `base`, so it always
        releases/closes whichever fd is current. last_frame is reset
        so the first frame is repainted on the new connection.
        """
        nonlocal base, node, last_frame, last_status_poll
        print("arctis-oled: HID device lost — waiting for base to reappear", flush=True)
        base.close()
        new = None
        while new is None:
            time.sleep(2)
            new = acquire_base()
        base = new
        node = new.node
        last_frame = None
        last_status_poll = 0.0
        try:
            base.poll_status()
        except Exception:
            pass
        print(f"arctis-oled: reconnected to {node}", flush=True)

    last_frame = None
    last_status_poll = 0.0
    last_stats_sample = 0.0
    last_push = 0.0
    scroll = 0
    base.poll_status()
    pc.sample()
    while True:
        try:
            now = time.time()
            if now - last_stats_sample >= 1.0:  # live PC info ticks at 1000ms
                pc.sample()
                last_stats_sample = now
            if now - last_status_poll > 20:
                base.poll_status()
                last_status_poll = now
            player = get_player(bus)
            playing = bool(player and player["status"] == "Playing")
            notif = notifs.current
            notif_active = bool(notif and now < notif[3])
            driving = bool(tel.fresh(now))
            state["released"] = False
            if playing:
                scroll += 2
            is_stats = False
            if notif_active:
                img = render_notif(notif)
            elif driving:
                img = render_drive(tel)
            else:
                page = int(now // PAGE_SECS) % 2
                if page == 0:
                    img = render_music(base, player, arts.get(player), scroll)
                else:
                    img = render_stats(base, pc)
                    is_stats = True
            raw = img.tobytes()
            force = is_stats and (now - last_push) >= 1.0  # stats page repaints at 1 Hz
            if raw != last_frame or force:
                base.push_frame(img)
                last_frame = raw
                last_push = now
        except OSError as e:
            # 19 ENODEV / 5 EIO / 32 EPIPE / 9 EBADF on the HID fd means
            # the base re-enumerated (or was unplugged) and our fd is
            # dead. Reopen instead of looping on the stale fd forever.
            if e.errno in (19, 5, 32, 9):
                try:
                    reopen_base()
                except Exception as re_e:
                    print(f"arctis-oled: reconnect failed (retrying): {re_e}", flush=True)
                    time.sleep(2)
            else:
                print(f"arctis-oled: loop error (continuing): {e}", flush=True)
                time.sleep(1)
        except Exception as e:
            print(f"arctis-oled: loop error (continuing): {e}", flush=True)
            time.sleep(1)
        time.sleep(0.25)
    return 0

if __name__ == "__main__":
    sys.exit(main())
