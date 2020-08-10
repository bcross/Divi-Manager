#!/bin/bash

function divi-mgr-install {
    if [ $EUID -ne 0 ]; then
        echo "Run this script with elevated privileges."
        exit 2
    fi
    if systemctl is-enabled divid.service 2>/dev/null | grep -Fq "enabled"; then
        echo "Divid has already been installed."
        return 1
    fi
    while true; do
        read -p "WARNING!!! This could be destructive to an existing divi wallet. Continue? [y/N] " encrypt
        case $encrypt in
            [Yy]* ) break;;
            * ) exit;;
        esac
    done
    homedir=$( getent passwd "$SUDO_USER" | cut -d: -f6 )
    #Create a user to run divid
    echo "Creating divid user"
    sudo useradd divid
    sudo chsh -s /bin/false divid
    sudo mkdir /home/divid

    #Install divi
    divi-mgr update

    #Generate first run files
    echo "Generating files"
    divid &>/dev/null
    #Generate random user and password
    RPC_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    RPC_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    #Write everything to divi.conf
cat <<EOT > ~/.divi/divi.conf
rpcuser=$RPC_USER
rpcpassword=$RPC_PASS
daemon=1
EOT
    #Clean existing folders
    rm /home/divid/.divi -r 2>/dev/null
    rm $homedir/.divi -r 2>/dev/null
    #Move .divi folder to divid user home directory
    sudo mv ~/.divi /home/divid -f
    #Copy divi.conf file back to current user for divi-cli use
    mkdir $homedir/.divi
    cp /home/divid/.divi/divi.conf $homedir/.divi -f
    owner=$(stat -c "%U %G" $homedir | sed 's/ /:/')
    sudo chown $owner $homedir/.divi -R
    #Repair permissions
    sudo chown divid:divid /home/divid -R

    #Download primer and nodes
    divi-mgr repair

    #Create and start service
    echo "Creating service"
sudo sh -c "cat <<EOT > /etc/systemd/system/divid.service
[Unit]
Description=DIVI's distributed currency daemon
After=network.target

[Service]
Type=forking
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5
User=divid
Group=divid
ExecStart=divid
ExecStop=divi-cli stop
ExecStopPost=/bin/bash -c \"while [ -f /home/divid/.divi/divid.pid ]; do sleep 1; done\"

[Install]
WantedBy=multi-user.target
EOT"
    sudo systemctl daemon-reload >/dev/null
    sudo systemctl enable divid.service >/dev/null
    #If run without arguments, start divid service
    if [ $# -eq 0 ] || [ "$1" != "0" ]; then
        sudo systemctl start divid.service
    else
        echo "Service not set to start. Exiting."
        echo "Remember to encrypt!"
        return 0
    fi
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
    divi-cli setstakesplitthreshold 20000 >/dev/null 2>&1
    while true; do
        read -p "Would you like to encrypt your wallet? [Y/n] " encrypt
        case $encrypt in
            [Nn]* ) break;;
            * ) 
                read -sp 'Wallet password: ' walletpass
                divi-cli encryptwallet "$walletpass" >/dev/null
                unset walletpass
                break
        esac
    done
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-install