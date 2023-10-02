#!/bin/bash

echo 0 > /tmp/notifyCount

notify() {
    if [ $1 -eq 0 ]; then
        echo $(($(head /tmp/notifyCount) + 1)) > /tmp/notifyCount
        (sleep 5 && echo $(($(head /tmp/notifyCount) - 1)) > /tmp/notifyCount; if [ $(head /tmp/notifyCount) -lt 1 ]; then notify-send -rpe $(head /tmp/notifyID) "$(asusctl profile -p)" > /tmp/notifyID; fi) &
        xdotool key alt
    else
        notify-send -rpe $(head /tmp/notifyID) "Please Authenticate asusd" > /tmp/notifyID
        systemctl start asusd
        echo $(($(head /tmp/notifyCount) - 1)) > /tmp/notifyCount
    fi
}

helpDialog() {
	echo "    "
	echo " Fixes the fan selector button on Asus laptops using asusctl."
	echo " Tested to work on Asus gaming laptops that have 'fn+F5' as the fan profile selector but in"
	echo " should work on any laptop asusctl work on"f
	echo " Here is some documentation for this horible program:"
	echo "    "
	echo "    asusfan [arguments]"
	echo "    "
	echo "    "
	echo "    -h                Help."
	echo "    -n  --no-notify   Don't display notifications when switching, its more responsive and uses less resources"
	echo "    -s  --splash      display splash when switching, similar to the ones used in windows. Not super responsive"
    echo "                      implies --no-notify."
	echo "    "
	echo "    --quiet	       Starts the script with setting the fan mode to Quiet by default."
	echo "    --balanced       Starts the script with setting the fan mode to Balanced by default."
	echo "    --performance    Starts the script with setting the fan mode to Performance by default."
	echo "    "
}

splash() {
    pkill -P $$
    ( yad \
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
    --sticky \
    --timeout=1 \
    --borders=0 ) & 
    
    # --center \
}

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

splashMode() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        asusctl profile -PQuiet
        if [[ "$lastMode" != "Quiet" ]]; then
            splash "Quiet"
        fi
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        asusctl profile -PBalanced
        if [[ "$lastMode" != "Balanced" ]]; then
            splash "Balanced"
        fi
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        asusctl profile -PPerformance
        if [[ "$lastMode" != "Performance" ]]; then
            splash "Performance"
        fi
        lastMode="Performance"
    fi
}

noNotify() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        asusctl profile -PQuiet
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        asusctl profile -PBalanced
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        asusctl profile -PPerformance
        lastMode="Performance"
    fi
}

fastMode() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        asusctl profile -PQuiet
        if [[ "$lastMode" != "Quiet" ]]; then
            notify-send \
                --icon="power-profile-power-saver-symbolic" \
                --urgency=critical \
                -rp \
                $(head /tmp/notifyID) \
                "$(asusctl profile -p)" \
                "The CPU will under-clock to use less power and make less noise." > /tmp/notifyID
            notify $?
        fi
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        asusctl profile -PBalanced
        if [[ "$lastMode" != "Balanced" ]]; then
            notify-send \
                --icon="power-profile-balanced-symbolic" \
                --urgency=critical \
                -rp \
                $(head /tmp/notifyID) \
                "$(asusctl profile -p)" \
                "This CPU will run at base clock to balance battery and performance, fan may ramp up under load." > /tmp/notifyID
            notify $?
        fi
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        asusctl profile -PPerformance
        if [[ "$lastMode" != "Performance" ]]; then
            notify-send \
                --icon="power-profile-performance-symbolic" \
                --urgency=critical \
                -rp \
                $(head /tmp/notifyID) \
                "$(asusctl profile -p)" \
                "The CPU will be allowed to boost-clock to ensure the best performance, fan will ramp up under small loads and uses more battery." > /tmp/notifyID
            notify $?
        fi
        lastMode="Performance"
    fi
}

if [[ $1 == "--quiet" || $2 == "--quiet" ]]; then
	asusctl profile -PQuiet && notify-send --icon="power-profile-power-saver-symbolic" -pe "Forced: $(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
    lastMode="Quiet"
elif [[ $1 == "--balanced" || $2 == "--balanced" ]]; then
	asusctl profile -PBalanced && notify-send --icon="power-profile-balanced-symbolic" -pe "Forced: $(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
    lastMode="Balanced"
elif [[ $1 == "--performance" || $2 == "--performance" ]]; then
	asusctl profile -PPerformance && notify-send --icon="power-profile-performance-symbolic" -pe "Forced: $(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
    lastMode="Performance"
elif [[ $1 == "-h" ]]; then
    helpDialog
	exit
else
	notify-send -pe "$(asusctl profile -p)" "Fan mode changer listening..."> /tmp/notifyID
    lastMode=$(asusctl profile -p | awk '{print $NF}')
fi


if [[ $1 == "--splash" || $2 == "--splash" || $1 == "-s" || $2 == "-s" ]]; then
    splash $lastMode
    while true; do
        output=$(acpi_listen -c 1)
		if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] || [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            splashMode
        fi
    done
elif [[ $1 == "--no-notify" || $2 == "--no-notify" || $1 == "-n" || $2 == "-n" ]]; then
    while true; do
        output=$(acpi_listen -c 1)
		if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] || [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            noNotify
        fi
    done
else
    while true; do
        output=$(acpi_listen -c 1)
		if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] || [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            fastMode
        fi
    done
fi
