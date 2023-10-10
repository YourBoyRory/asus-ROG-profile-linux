#!/bin/bash

userName=$(getent passwd "$USER" | cut -d ':' -f 3 | cut -d ',' -f 1)

mkdir ~/.config/asusFanDriver/ 2> /dev/null
cd ~/.config/asusFanDriver/
rogCfg="./rog.cfg"
fanCfg="./fan.cfg"
splashBootDelay=5
touch /tmp/notifyCount_$userName
touch /tmp/notifyID_$userName

echo 0 > /tmp/notifyCount_$userName

readConfig() {
    # ROG Var
    rogLEDStartup=$(grep -oP '^rogLEDStartup=\K.*' $rogCfg | head -n1 )
    rogCLRMode=$(grep -oP '^rogCLRMode=\K.*' $rogCfg | head -n1 )
    rogCLRSpeed=$(grep -oP '^rogCLRSpeed=\K.*' $rogCfg | head -n1 )
    rogPrimaryCLR=$(grep -oP '^rogPrimaryCLR=\K.*' $rogCfg | head -n1 )
    rogSecondaryCLR=$(grep -oP '^rogSecondaryCLR=\K.*' $rogCfg | head -n1 )
    
    # Fan
    rogFanDisplayMode=$(grep -oP '^rogFanDisplayMode=\K.*' $fanCfg | head -n1 )
    rogDefaultFanMode=$(grep -oP '^rogDefaultFanMode=\K.*' $fanCfg | head -n1 )
}

notify() {
    notify-send --icon="$1" --urgency=critical -rp $(head /tmp/notifyID_$userName) "$2" "$3" > /tmp/notifyID_$userName
    echo $(($(head /tmp/notifyCount_$userName) + 1)) > /tmp/notifyCount_$userName
    (
        userName=$(getent passwd "$USER" | cut -d ':' -f 3 | cut -d ',' -f 1)
        sleep 5 
        echo $(($(head /tmp/notifyCount_$userName) - 1)) > /tmp/notifyCount_$userName
        if [ $(head /tmp/notifyCount_$userName) -lt 1 ]; then 
            notify-send --icon="$1" -rpe $(head /tmp/notifyID_$userName "$2" "$3" > /tmp/notifyID_$userName)
        fi
    ) &
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
	echo "    "
	echo "    --quiet	       Starts the script with setting the fan mode to Quiet by default."
	echo "    --balanced       Starts the script with setting the fan mode to Balanced by default."
	echo "    --performance    Starts the script with setting the fan mode to Performance by default."
	echo "    "
}


splash() {
    pkill -P $$ yad
    ( 
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
            (
                notify "power-profile-power-saver-symbolic" "$(asusctl profile -p)" "The CPU will under-clock to use less power and make less noise." 
            )&
        fi
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        if [[ "$lastMode" != "Balanced" ]]; then
            (
                notify "power-profile-balanced-symbolic" "$(asusctl profile -p)" "This CPU will run at base clock to balance battery and performance, fan may ramp up under load." 
            )&
        fi
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        if [[ "$lastMode" != "Performance" ]]; then
            (
                notify "power-profile-performance-symbolic" "$(asusctl profile -p)" "The CPU will be allowed to boost-clock to ensure the best performance, fan will ramp up under small loads and uses more battery." 
            )&
        fi
        lastMode="Performance"
    fi
}

notifyStandAlone() {
    if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
        (
            notify "power-profile-power-saver-symbolic" "$(asusctl profile -p)" "The CPU will under-clock to use less power and make less noise."
        )&
        lastMode="Quiet"
    elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
        (
            notify "power-profile-balanced-symbolic" "$(asusctl profile -p)" "This CPU will run at base clock to balance battery and performance, fan may ramp up under load."
        )&
        lastMode="Balanced"
    elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
        (
            notify "power-profile-performance-symbolic" "$(asusctl profile -p)" "The CPU will be allowed to boost-clock to ensure the best performance, fan will ramp up under small loads and uses more battery."
        )&
        lastMode="Performance"
    fi
}

sendBootNotify() {
    if [[ "$1" == "Quiet" ]]; then
        notify-send \
            --icon="power-profile-power-saver-symbolic"\
            -pe \
            "Forced: $(asusctl profile -p)" \
            "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID_$userName
    elif [[ "$1" == "Balanced" ]]; then
        notify-send \
            --icon="power-profile-balanced-symbolic" \
            -pe \
            "Forced: $(asusctl profile -p)" \
            "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID_$userName
    elif [[ "$1" == "Performance" ]]; then
        notify-send \
        --icon="power-profile-performance-symbolic" \
        -pe \
        "Forced: $(asusctl profile -p)" \
        "Default fan mode loaded. Fan control is listening..." > /tmp/notifyID_$userName
    else
        if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
            notify-send \
                --icon="power-profile-power-saver-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID_$userName
        elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
            notify-send \
                --icon="power-profile-balanced-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID_$userName
        elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
            notify-send \
                --icon="power-profile-performance-symbolic" \
                -pe \
                "$(asusctl profile -p)" \
                "Loaded last profile. Fan control is listening..." > /tmp/notifyID_$userName
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

runDriver() {
    if [[ $1 == "--splash" || $2 == "--splash" || $1 == "-s" || $2 == "-s" || $rogFanDisplayMode == "Splash" ]]; then
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
    else
        while [[ $error -eq 0 ]] ; do
            output=$(acpi_listen -c 1)
            error=$?
            if [[ $output == " 0B3CBB35-E3C2- 000000ff 00000000" ]] ; then
                notifyMode
                asusdCheck &
            elif [[ $output == "battery PNP0C0A:00 00000080 00000001" ]] ; then
                notifyStandAlone
                asusdCheck &
            fi
        done
    fi
    notify-send "Please Authenticate ACPI" "Enable acpid with systemctl to prevent this popup"
    systemctl start acpid
    asusdCheck
    sleep 5
    runDriver
}

mainCML() {
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
        sendBootNotify
        lastMode=$(asusctl profile -p | awk '{print $NF}')
    fi
    runDriver $1 $2
}

main() {
    asusdCheck
    if [[ "$rogDefaultFanMode" == "Quiet" ]]; then
        asusctl profile -PQuiet && sendBootNotify "Quiet"
        lastMode="Quiet"
    elif [[ "$rogDefaultFanMode" == "Balanced" ]]; then
        asusctl profile -PBalanced && sendBootNotify "Balanced"
        lastMode="Balanced"
    elif [[ "$rogDefaultFanMode" == "Performance" ]]; then
        asusctl profile -PPerformance && sendBootNotify "Performance"
        lastMode="Performance"
    else
        sendBootNotify
        lastMode=$(asusctl profile -p | awk '{print $NF}')
    fi
    runDriver $1 $2
}

readConfig

if [[ $rogLEDStartup == "TRUE" ]] ; then
    if [[ $rogCLRMode == "Rainbow" ]] ; then
        asusctl led-mode strobe -s $rogCLRSpeed
    elif [[ $rogCLRMode == "Breathe" ]] ; then
        asusctl led-mode breathe -c ${rogPrimaryCLR:1} -C ${rogSecondaryCLR:1} -s $rogCLRSpeed
    elif [[ $rogCLRMode == "Pulse" ]] ; then
        asusctl led-mode pulse -c ${rogPrimaryCLR:1}
    else 
        asusctl led-mode static -c ${rogPrimaryCLR:1}
    fi
fi 

if [[ $rogFanDisplayMode != "None" ]] ; then
    if [[ "$1" != "" ]] ; then
        if [[ $1 == "-h" ]]; then
            helpDialog
            exit
        elif [[ "$1" == "--splash" || "$1" == "-s" && $2 == "" ]]  ; then
            main
        else 
            mainCML $1 $2
        fi
    else
        main
    fi
fi

