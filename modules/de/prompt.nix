{
  home =
    { inputs, allModules, ... }:
    {
      programs = {
        bash.enable = true;
        oh-my-posh = {
          enable = true;
          enableBashIntegration = true;
          settings = {
            "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
            palette =
              let
                count = 8;
                # Pansexual flag palette (barbados, 2026-11-01, Shorki's
                # request — matches the kitty palette + shaderbg wallpaper).
                # Was a generated rainbow ramp; now the flag's pink, yellow
                # and cyan family, all bright enough for black segment text.
                palette = [
                  "#FF218C"
                  "#FF5CA8"
                  "#FF8FC0"
                  "#FFD800"
                  "#FFE14D"
                  "#21B1FF"
                  "#54C8FF"
                  "#7FDBFF"
                ];
              in
              {
                "red" = "#FF218C";
                "green" = "#21B1FF";
                "blue" = "#1E90D6";
                "white" = "#FFFFFF";
                "black" = "#111111";
              }
              // builtins.listToAttrs (
                builtins.genList (i: {
                  name = toString i;
                  value = builtins.elemAt palette i;
                }) count
              );
            blocks = [
              {
                alignment = "left";
                segments = [
                  {
                    background = "p:0";
                    foreground = "p:black";
                    leading_diamond = "╭─";
                    style = "diamond";
                    template = "{{.Icon}} ";
                    type = "os";
                  }
                  {
                    background = "p:1";
                    foreground = "p:black";
                    powerline_symbol = "";
                    style = "powerline";
                    template = " {{if .Env.IN_NIX_SHELL}}{{.Env.IN_NIX_SHELL}} nix shell{{else}}{{.Name}}{{end}} ";
                    type = "shell";
                  }
                  {
                    background = "p:2";
                    foreground = "p:black";
                    powerline_symbol = "";
                    style = "powerline";
                    template = " {{ .UserName }} ";
                    type = "session";
                  }
                  {
                    background = "p:3";
                    foreground = "p:black";
                    powerline_symbol = "";
                    style = "powerline";
                    template = " {{ .HostName }} ";
                    type = "session";
                  }
                  {
                    background = "p:4";
                    foreground = "p:black";
                    powerline_symbol = "";
                    properties = {
                      style = "full";
                    };
                    style = "powerline";
                    template = " {{ .Path }} ";
                    type = "path";
                  }
                  {
                    background = "p:5";
                    foreground = "p:black";
                    powerline_symbol = "";
                    properties = {
                      "branch_icon" = " ";
                      "fetch_status" = true;
                      "fetch_upstream_icon" = true;
                    };
                    style = "powerline";
                    template = " {{ .UpstreamIcon }} {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}</>{{ end }} ";
                    type = "git";
                  }
                  {
                    background = "p:6";
                    foreground = "p:black";
                    properties = {
                      style = "roundrock";
                      threshold = 0;
                    };
                    style = "diamond";
                    template = " {{ .FormattedMs }}⠀";
                    trailing_diamond = "";
                    type = "executiontime";
                  }
                ];
                type = "prompt";
              }
              {
                alignment = "right";
                segments = [
                  {
                    background = "p:7";
                    foreground = "p:black";
                    invert_powerline = true;
                    properties = {
                      time_format = "Jan _2, 15:04";
                    };
                    style = "diamond";
                    template = " {{ .CurrentDate | date .Format }} ";
                    leading_diamond = "";
                    trailing_diamond = "";
                    type = "time";
                  }
                ];
                type = "prompt";
              }
              {
                alignment = "left";
                newline = true;
                segments = [
                  {
                    foreground = "p:0";
                    style = "plain";
                    template = "╰─";
                    type = "text";
                  }
                  {
                    foreground = "p:0";
                    properties = {
                      always_enabled = true;
                    };
                    style = "plain";
                    template = " ";
                    type = "status";
                  }
                ];
                type = "prompt";
              }
            ];
            secondary_prompt = {
              foreground = "p:0";
              template = " ";
            };
            version = 3;
          };
        };
      };
    };
}
