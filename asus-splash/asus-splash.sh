#!/bin/bash

last_power_state=$(asusctl profile -p | tail -n1 | awk '{print $NF}')

getCenter() {
    imageX=250
    if [[ $1 == "X" ]]; then
        Xaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1) # finds screen width
        echo $(( ($Xaxis/2)-($imageX/2 )))
    elif [[ $1 == "Y" ]]; then
        Yaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2) # finds screen height
        echo $(( (($Yaxis/2)-($imageX/2))+150 ))
    fi
}

splash() {
    pkill -P $$ yad
    ( 
        GDK_BACKEND=x11 yad \
        --no-buttons \
        --on-top \
        --undecorated \
        --skip-taskbar \
        --no-focus \
        --posx=$(getCenter X) \
        --posy=$(getCenter Y) \
        --splash \
        --text-align=center \
        --image="/opt/asus-ROG-profile-linux/assets/$1.png" \
        --timeout=1 \
        --borders=0 
    ) & 
}

while [[ $error -eq 0 ]] ; do
    event=$(acpi_listen -c 1)
    error=$?
    if [[ $event == "wmi PNP0C14:00 000000ff 00000000"  ]]; then
        power_state=$(asusctl profile -p | tail -n1 | awk '{print $NF}')
        if [[ $power_state != $last_power_state ]]; then
            last_power_state=$power_state
            splash $power_state
        fi
    fi
done
