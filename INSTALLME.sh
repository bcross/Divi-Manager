if [ ! -z $EUID ] && [ $EUID -ne 0 ]; then
  echo "Run this script with elevated privileges."
  exit 2
fi
wget -q https://github.com/bcross/Divi-Manager/archive/master.zip
unzip -qqo master.zip
rm master.zip Divi-Manager-master/INSTALLME Divi-Manager-master/LICENSE Divi-Manager-master/README.md
sudo cp -rf Divi-Manager-master/* /usr/local/bin
sudo chmod +x /usr/local/bin/divi-mgr
rm Divi-Manager-master -r
