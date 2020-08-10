# Divi-Manager
## TL;DR
    wget -q https://github.com/bcross/Divi-Manager/archive/master.zip
    unzip master.zip
    rm mater.zip Divi-Manager-master/LICENSE Divi-Manager-master/README.md
    sudo cp -rf Divi-Manager-master/* /usr/local/bin
    sudo chmod +x /usr/local/bin/divi-mgr
    rm Divi-Manager-master -r
## Warnings
Running `divi-mgr install` removes .divi in the caller's home directory. This could be hazardous to your wallet. Make sure you want to do this.
Running `divi-mgr repair` or `divi-mgr update` *will* restart the divid service. Running `divi-mgr validate` might restart the divid service if necessary.
