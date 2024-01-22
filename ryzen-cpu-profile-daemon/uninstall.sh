#!/bin/bash

sudo rm /opt/asus-ROG-profile-linux/cpu-profile-daemon.sh
sudo systemctl stop cpu-profile-daemon.service
sudo systemctl disable cpu-profile-daemon.service
sudo rm /etc/systemd/system/cpu-profile-daemon.service
sudo systemctl daemon-reload
