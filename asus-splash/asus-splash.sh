#!/bin/bash

splashBootDelay=3

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
	echo "    "
	echo "    --quiet	       Starts the script with setting the fan mode to Quiet by default."
	echo "    --balanced       Starts the script with setting the fan mode to Balanced by default."
	echo "    --performance    Starts the script with setting the fan mode to Performance by default."
	echo "    "
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
	powProfile=$(powerprofilesctl get)
    if [[ "$powProfile" == "power-saver" ]]; then
        if [[ "$lastMode" != "Quiet" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Quiet"
    elif [[ "$powProfile" == "balanced" ]]; then
        if [[ "$lastMode" != "Balanced" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Balanced"
    elif [[ "$powProfile" == "performance" ]]; then
        if [[ "$lastMode" != "Performance" ]]; then
            splash "$(asusctl profile -p | awk '{print $NF}')"
        fi
        lastMode="Performance"
    fi
}

splashStandAlone() {
	sleep 2
	powProfile=$(powerprofilesctl get)
    if [[ "$powProfile" == "power-saver" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Quiet"
    elif [[ "$powProfile" == "balanced" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Balanced"
    elif [[ "$powProfile" == "performance" ]]; then
        splash "$(asusctl profile -p | awk '{print $NF}')"
        lastMode="Performance"
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

runDriver() {
    (bootSplash $lastMode $splashBootDelay ) &
    error=0
    while [[ $error -eq 0 ]] ; do
        output=$(acpi_listen -c 1)
        error=$?
        if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] ; then
            splashMode
            asusdCheck
        elif [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
            splashStandAlone
            asusdCheck
        fi
    done
    notify-send "Please Authenticate ACPI" "Enable acpid with systemctl to prevent this popup"
    systemctl start acpid
    asusdCheck
    sleep 5
    runDriver
}

main() {
    asusdCheck
    if  [[ $1 == "--quiet" || $2 == "--quiet" ]] ; then
        asusctl profile -PQuiet && sendBootNotify "Quiet"
        lastMode="Quiet"
    elif [[ $1 == "--balanced" || $2 == "--balanced" ]]; then
        asusctl profile -PBalanced && sendBootNotify "Balanced"
        lastMode="Balanced"
    elif [[ $1 == "--performance" || $2 == "--performance" ]]; then
        asusctl profile -PPerformance && sendBootNotify "Performance"
        lastMode="Performance"
    else
        lastMode=$(asusctl profile -p | awk '{print $NF}')
    fi
    runDriver $1 $2
}

if [[ $rogFanDisplayMode != "None" ]] ; then
    if [[ $1 == "-h" ]]; then
        helpDialog
        exit
    else
        main $1
    fi
fi

