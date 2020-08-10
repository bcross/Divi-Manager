#!/bin/bash

function divi-mgr-update {
    if [ $EUID -ne 0 ]; then
        echo "Run this script with elevated privileges."
        exit 2
    fi
    #If an argument is given, use it as the location of divi binaries
    if [ $# -eq 0 ]; then
        DIVIBIN=/usr/local/bin
    else
        DIVIBIN=${1%/}
    fi
    #Download and extract the latest Divi release
    echo "Downloading divi"
    mkdir divitemp
    wget -qO- https://api.github.com/repos/DiviProject/Divi/releases/latest \
    | grep "divi-.*-x86_64-linux-gnu.tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -O divi.tar.gz -qi - 
    tar -xzf divi.tar.gz -C divitemp
    #If divid service is enabled, stop it
    if systemctl is-enabled divid.service 2>/dev/null | grep -Fq "enabled"; then
        echo "Stopping divid"
        sudo systemctl stop divid
    fi
    #Replace the Divi binaries
    echo "Moving divi binaries"
    sudo mv divitemp/divi-*/bin/* $DIVIBIN -f
    #If divid service is enabled, start it
    if systemctl is-enabled divid.service 2>/dev/null | grep -Fq "enabled"; then
        echo "Starting divid"
        sudo systemctl start divid
    fi
    #Clean up files
    rm divi.tar.gz
    rm divitemp -r
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-update