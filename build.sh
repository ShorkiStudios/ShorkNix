git add --all

command=$1;

if [ "$1" == "" ]; then
    command="switch"
fi

nh os $command . --show-trace "${@:2}"
