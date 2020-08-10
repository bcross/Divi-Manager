#!/bin/bash

function divi-mgr-repair {
    if [ $EUID -ne 0 ]; then
        echo "Run this script with elevated privileges."
        exit 2
    fi
    #If an argument is given, use it as the .divi folder path
    if [ $# -eq 0 ]; then
        DOTDIVI=/home/divid/.divi
    else
        DOTDIVI=${1%/}
    fi
    #Download and extract the latest Divi snapshot
    echo "Downloading divi snapshot"
    wget -q https://snapshots.diviproject.org/dist/DIVI-snapshot.tar.gz
    echo "Extracting divi snapshot"
    tar -xzf DIVI-snapshot.tar.gz
    rm DIVI-snapshot.tar.gz
    echo "Adding nodes to divi.conf"
    #Remove nodes
    sudo sed -i '/addnode=.*/d' $DOTDIVI/divi.conf
    #Get nodes
    until grep -q "addnode=" <<< "$nodes"
    do
        nodes=$(wget -qO- https://api.diviproject.org/v1/addnode)
    done
    #Add nodes
    sudo printf "$nodes\n" >> $DOTDIVI/divi.conf
    #If divid service is enabled, stop it
    if systemctl is-enabled divid.service 2>/dev/null | grep -Fq "enabled"; then
        echo "Stopping divid"
        sudo systemctl stop divid
    fi
    #Delete everything except the backups folder and debug.log, masternode.conf, wallet.dat, and divi.conf files
    echo "Removing files"
    sudo find $DOTDIVI ! -path "*/.divi" ! -path "*/backups*" ! -name "debug.log" ! -name "masternode.conf" ! -name "wallet*.dat" ! -name "divi.conf" -exec sudo rm -r -f {} +
    #Move the extracted snapshot into place
    echo "Moving snapshot into place"
    sudo mv blocks $DOTDIVI
    sudo mv chainstate $DOTDIVI
    #Repair permissions
    owner=$(stat -c "%U %G" $DOTDIVI/../ | sed 's/ /:/')
    sudo chown $owner $DOTDIVI -R
    #If divid service is enabled, start it
    if systemctl is-enabled divid.service 2>/dev/null | grep -Fq "enabled"; then
        echo "Starting divid"
        sudo systemctl start divid
    fi
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-repair