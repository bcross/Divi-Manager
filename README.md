# Divi Manager
## Install
    wget -q https://github.com/bcross/Divi-Manager/archive/master.zip
    unzip master.zip
    rm master.zip Divi-Manager-master/LICENSE Divi-Manager-master/README.md
    sudo cp -rf Divi-Manager-master/* /usr/local/bin
    sudo chmod +x /usr/local/bin/divi-mgr
    rm Divi-Manager-master -r
## Warnings
Running `divi-mgr install` removes .divi in the caller's home directory. This could be hazardous to your wallet. Make sure you want to do this.
Running `divi-mgr repair` or `divi-mgr update` *will* restart the divid service. Running `divi-mgr validate` might restart the divid service if necessary.

## Commands
* divi-mgr install (requires sudo)
  * Creates a divid user, Installs divi into /usr/local/bin, creates a divid service, sets setstakesplitthreshold, and encrypts wallet.
* divi-mgr repair (requires sudo)
  * Repairs a broken divi install by copying the snapshot and following the instructions found [here](https://snapshots.diviproject.org). A path to a data directory is optional.
* divi-mgr stake
  * Waits for all indicators to be green for staking then prompts for wallet password.
* divi-mgr update (requires sudo)
  * Updates divi. A path to where the binaries to be extracted to is optional.
* divi-mgr verify (requires sudo) (coming soon)
  * Verifies divi is not broken. Runs `divi-mgr repair` if necessary.
