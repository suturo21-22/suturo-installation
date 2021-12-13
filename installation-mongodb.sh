#!/bin/bash
# IMPORTANT: if you want to upgrade to a newer version than ubuntu 20.04 then change the focal in the following line
# This is used in the apt sources
# version="focal"
# alternative automatic version detection. Use at your own risk:
if [ -z "$version" ]; then
    version=$(source /etc/os-release; [ -z "$UBUNTU_CODENAME" ] && echo $VERSION_CODENAME || echo $UBUNTU_CODENAME)
fi

if dpkg -l 'mongodb*' | grep -E '^.?i'; then
    echo "There is already a package with 'mongo' in the name installed"
    exit 4
fi

if grep "mongodb" -r /etc/apt/sources.list.d; then
    echo "There is a file in /etc/apt/sources.lsit.d containing mongodb."
    echo "Refusing to do automatic installation since there may be unintended side effects."
    exit 4
fi

curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${version}/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install mongodb-org

# Test if mongodb is running
echo "Checking if mongod will start"
sudo systemctl start mongod.service
sleep 5
if ! sudo systemctl status mongod; then
    echo 'Error: mongod couldn'"'"'t be started'
    # if it is not running try the following and see if there are any error messages:
    echo 'Starting it manually to see errors:'
    (umask 022; sudo -u mongodb sh -c '/usr/bin/mongod --config /etc/mongod.conf; echo "Exit Code: $?"')
    echo
    read -p "If this script should try to resolve the issue by cleaning the folder '/var/lib/mongodb', enter 'yes'" del
    if [ "$del" != "yes" ]; then
	echo "please resolve the issue manually"
	exit 2
    fi
    sudo mv /var/lib/mongodb ./mongodb-$(date +%F--%H-%M-%S)-backup
    echo "Checking if mongod will start now"
    sudo systemctl start mongod.service
    sleep 5
    if ! sudo systemctl status mongod; then
	echo "mongod will still not start, please resolve the issue manually"
	exit 3
    fi
fi

# if `active (running)` is there (in green) check the version
mongo --eval 'db.runCommand({ connectionStatus: 1 })'
# if version is 4.4.5 or higher, everything went right and you can enable it
read -p 'Is the version you see at least 4.4.5? (y/n) ' enable
if [ "$enable" = "y" ]; then
    echo "Enabling mongod service"
    sudo systemctl enable mongod
    echo "Installation of mongodb complete"
    exit 0
else
    echo "Please install mongodb manually"
    exit 1
fi
