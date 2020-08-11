#!/bin/bash

function divi-mgr-stake {
    echo "Waiting for divid to be ready..."
    #While not ready
    while true; do
        #Get mnsync status and extract relevant variables
        mnsync=$(divi-cli mnsync status 2>/dev/null)
        if [ -z "$mnsync" ]; then
            sleep 5
            continue
        fi
        synced=$(echo $mnsync | grep -Po '"IsBlockchainSynced" : \K[true|false]+')
        reqmnassets=$(echo $mnsync | grep -Po '"RequestedMasternodeAssets" : \K\d+')
        reqmnattempt=$(echo $mnsync | grep -Po '"RequestedMasternodeAttempt" : \K\d+')
        #If the variables are within parameters, we are ready to stake
        if [ "$synced" == "true" ] && [ $reqmnassets -eq 999 ] && [ $reqmnattempt -eq 0 ]; then
            break
        #Otherwise, wait 5 seconds and check again
        else
            sleep 5
        fi
    done
    #Read the wallet passphrase secretly and unlock for staking
    read -sp 'Wallet password: ' walletpass
    echo
    divi-cli walletpassphrase "$walletpass" 0 true
    #Clear the walletpass variable as soon as possible
    unset walletpass
}

#If script is being run independently, run function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && divi-mgr-stake
