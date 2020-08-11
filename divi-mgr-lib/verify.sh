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
    #If stuck at block 100 for 3 minutes, repair
    while [ $blockcount -eq 100 ] && [ $badtime -le 18 ]; do
        sleep 10
        blockcount=$(divi-cli getblockcount)
        let "badtime++"
    done
    #Get the block hash locally
    blockhash=$(divi-cli getblockhash $blockcount)
    #Get the block hash from a trusted source
    trustedblockhash=$(wget -qO- "https://chainz.cryptoid.info/divi/api.dws?q=getblockhash&height=$blockcount" | sed 's/"//g')
    #If the block count is greater than 100 and the block hashes match, all is well
    if [ $blockcount -gt 100 ] && [ "$blockhash" == "$trustedblockhash" ]; then
        allgood=1
    fi
    if [ $allgood -eq 0 ]; then
        divi-mgr repair
    fi
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-verify
