#!/bin/bash

sudo mkdir /opt/asus-ROG-profile-linux/
sudo mkdir /opt/asus-ROG-profile-linux/assets
sudo cp ./assets/*.png /opt/asus-ROG-profile-linux/assets
sudo cp ./asusfan.sh /usr/local/bin/asusfan
sudo cp ./configGUI.sh /usr/local/bin/asusfan-config
sudo chmod 755 /opt/asus-ROG-profile-linux/
sudo chmod 755 /opt/asus-ROG-profile-linux/assets
sudo chmod 744 /opt/asus-ROG-profile-linux/assets/*.png
sudo chmod 755 /usr/local/bin/asusfan
sudo chmod 755 /usr/local/bin/asusfan-config
