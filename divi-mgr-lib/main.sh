#!/bin/bash

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && echo "Run divi-mgr instead" && exit

parent_path="$(dirname ${BASH_SOURCE[0]})"

#Import functions
source $parent_path/install.sh
source $parent_path/repair.sh
source $parent_path/stake.sh
source $parent_path/update.sh
source $parent_path/verify.sh

function main() {

    #Create the command table
    declare -A -x command_table=(
        ['install']="divi-mgr-install"
        ['repair']="divi-mgr-repair"
        ['stake']="divi-mgr-stake"
        ['update']="divi-mgr-update"
        ['verify']="divi-mgr-verify"
    )

    #If no arguments are present, display possible arguments
    local commands="${!command_table[@]}"
    local msg="usage: divi-mgr [ $commands ]"
    if [[ $# < 1 ]]; then echo $msg; return 1; fi

    #Get the command and remove it from the argument array
    local command=${1}; shift
    #Get the function name from the command table
    local fn_name=${command_table[$command]}

    #If the function name is not found in the command table, display possible arguments
    if [[ $fn_name == '' ]]; then exit_with_help "$msg"; fi
    #Run the function
    if $fn_name $@; then return 0; else return 1; fi
}
