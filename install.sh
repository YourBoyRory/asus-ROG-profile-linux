#!/bin/bash

sudo mkdir /opt/asus-ROG-profile-linux/
sudo mkdir /opt/asus-ROG-profile-linux/assets
sudo cp ./assets/*.png /opt/asus-ROG-profile-linux/assets
sudo cp ./asusfan.sh /usr/local/bin/asusfan
sudo chmod 755 /usr/local/bin/asusfan
