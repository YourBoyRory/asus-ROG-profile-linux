#!/bin/bash

splashBootDelay=5
echo 0 > /tmp/notifyCount

notify() {
    notify-send --icon="$1" --urgency=critical -rp $2 "$3" "$4" > /tmp/notifyID
    echo $(($(head /tmp/notifyCount) + 1)) > /tmp/notifyCount
    (sleep 5 && echo $(($(head /tmp/notifyCount) - 1)) > /tmp/notifyCount; if [ $(head /tmp/notifyCount) -lt 1 ]; then notify-send -rpe $(head /tmp/notifyID) "$(asusctl profile -p)" > /tmp/notifyID; fi) &
    xdotool key alt
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
    
}

bootSplash() {
    sleep $2
    yad \
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
    --borders=0
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
        if [[ "$lastMode" != "Quiet" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        if [[ "$lastMode" != "Balanced" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        if [[ "$lastMode" != "Performance" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Performance"
    fi
}

splashStandAlone() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Performance"
    fi
}

notifyMode() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        if [[ "$lastMode" != "Quiet" ]]; then
            notify "power-profile-power-saver-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "The CPU will under-clock to use less power and make less noise."
        fi
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        if [[ "$lastMode" != "Balanced" ]]; then
            notify "power-profile-balanced-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "This CPU will run at base clock to balance battery and performance, fan may ramp up under load."
        fi
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        if [[ "$lastMode" != "Performance" ]]; then
            notify "power-profile-performance-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "The CPU will be allowed to boost-clock to ensure the best performance, fan will ramp up under small loads and uses more battery." > /tmp/notifyID
        fi
        lastMode="Performance"
    fi
}

notifyStandAlone() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        notify "power-profile-power-saver-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "The CPU will under-clock to use less power and make less noise."
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        notify "power-profile-balanced-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "This CPU will run at base clock to balance battery and performance, fan may ramp up under load."
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        notify "power-profile-performance-symbolic" $(head /tmp/notifyID) "$(asusctl profile -p)" "The CPU will be allowed to boost-clock to ensure the best performance, fan will ramp up under small loads and uses more battery." > /tmp/notifyID
        lastMode="Performance"
    fi
}

sendBootNotify() {
    if [[ "$1" == "Quiet" ]]; then
        notify-send \
            --icon="power-profile-power-saver-symbolic"\
            -pe \
            "Forced: $(asusctl profile -p)" \
            "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID
    elif [[ "$1" == "Balanced" ]]; then
        notify-send \
            --icon="power-profile-balanced-symbolic" \
            -pe \
            "Forced: $(asusctl profile -p)" \
            "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID
    elif [[ "$1" == "Performance" ]]; then
        notify-send \
        --icon="power-profile-performance-symbolic" \
        -pe \
        "Forced: $(asusctl profile -p)" \
        "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID
    else
        if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
            notify-send \
                --icon="power-profile-power-saver-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID
        elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
            notify-send \
                --icon="power-profile-balanced-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID
        elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
            notify-send \
                --icon="power-profile-performance-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID
        fi
    fi
}

asusdCheck() {
    passed=0
    while [ $passed -eq 0 ] ; do
        asusctl | grep "print help message" >> /dev/null
        if [ $? -ne 0 ] ; then
            notify-send "Please Authenticate ASUSD" "Enable asusd with systemctl to prevent this popup"
            systemctl start asusd
            sleep 5
        else
            passed=1
        fi
    done
}

asusdCheck
if [[ $1 == "--quiet" || $2 == "--quiet" ]]; then
    asusctl profile -PQuiet && sendBootNotify "Quiet"
    lastMode="Quiet"
elif [[ $1 == "--balanced" || $2 == "--balanced" ]]; then
    asusctl profile -PBalanced && sendBootNotify "Balanced"
    lastMode="Balanced"
elif [[ $1 == "--performance" || $2 == "--performance" ]]; then
    asusctl profile -PPerformance && sendBootNotify "Performance"
    lastMode="Performance"
elif [[ $1 == "-h" ]]; then
    helpDialog
    exit
else
    sendBootNotify
    lastMode=$(asusctl profile -p | awk '{print $NF}')
fi



if [[ $1 == "--splash" || $2 == "--splash" || $1 == "-s" || $2 == "-s" ]]; then
    (bootSplash $lastMode $splashBootDelay ) &
    while true; do
        output=$(acpi_listen -c 1)
        error=$?
		if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] ; then
            splashMode
            asusdCheck &
        elif [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            splashStandAlone
            asusdCheck &
        elif [ $error -eq 1 ] ; then
            notify-send "Please Authenticate ACPI" "Enable acpid with systemctl to prevent this popup"
            systemctl start acpid
            sleep 5
            asusdCheck
        fi
    done
else
    while true; do
        output=$(acpi_listen -c 1)
        error=$?
		if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] ; then
            notifyMode
            asusdCheck &
        elif [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            notifyStandAlone
            asusdCheck &
        elif [ $error -eq 1 ] ; then
            notify-send "Please Authenticate ACPI" "Enable acpid with systemctl to prevent this popup"
            systemctl start acpid
            sleep 5
            asusdCheck
        fi
    done
fi
