#!/bin/bash

sudo pacman -S tk pyudev asusctl rog-control-center
sudo systemctl enable --now asusd.service
cp ./rog-control-center.desktop ~/.config/autostart/

sudo mkdir -p /usr/local/share/power-profile-splash-service/assets
sudo cp ./power-profile-service.py /usr/local/bin/power-profile-splash-service
sudo cp -r ./assets/*.png /usr/local/share/power-profile-splash-service/assets/
sudo chmod 755 /usr/local/bin/power-profile-splash-service
sudo chmod 555 /usr/local/share/power-profile-splash-service/
sudo chmod 555 /usr/local/share/power-profile-splash-service/assets
sudo chmod 444 /usr/local/share/power-profile-splash-service/assets/*.png

mkdir -p ~/.config/systemd/user
cp ./update-checker.service  ~/.config/systemd/user/power-profile-splash.service
systemctl --user daemon-reload
systemctl --user enable --now power-profile-splash.service
