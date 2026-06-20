git add --all

command=$1;

if [ "$1" == "" ]; then
    command="switch"
fi

nixos-rebuild $command --flake /etc/shorknix#barbados --impure --show-trace "${@:2}"
