#!/bin/bash
#lets boot quite please
lastProfile="NONE"
while true; do 
    prifileOut=$(powerprofilesctl get)
    if [[ "$prifileOut" == "power-saver" && "$lastProfile" != "power-saving" ]]; then
        ryzenadj --power-saving
        lastProfile="power-saving"
    elif [[ "$prifileOut" != "power-saver" && "$lastProfile" != "max-performance" ]]; then
        sudo ryzenadj --max-performance
        lastProfile="max-performance"
    fi
    sleep 2
done
