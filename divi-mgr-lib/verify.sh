#!/bin/bash

function divi-mgr-verify {
    echo "Waiting for divid to be ready..."
    ready=0
    while [ $ready -eq 0 ]; do
        #Get info and wait for no error
        info=$(divi-cli getinfo 2>/dev/null)
        if [ -z "$info" ]; then
            sleep 5
            continue
        else
            break
        fi
    done
    allgood=0
    blockcount=$(divi-cli getblockcount)
    blockhash=$(divi-cli getblockhash $blockcount)
    trustedblockhash
    if [ $allgood -eq 0 ]; then
    divi-mgr repair
    fi
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-install