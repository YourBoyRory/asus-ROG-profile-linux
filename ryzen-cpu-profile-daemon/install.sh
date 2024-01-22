#!/bin/bash

sudo mkdir /opt/asus-ROG-profile-linux/
sudo chmod 755 /opt/asus-ROG-profile-linux/

sudo cp ./cpu-profile-daemon.sh /opt/asus-ROG-profile-linux/cpu-profile-daemon.sh
sudo cp ./cpu-profile-daemon.service /etc/systemd/system/cpu-profile-daemon.service
sudo systemctl daemon-reload
sudo systemctl enable --now cpu-profile-daemon.service
