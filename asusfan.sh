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

splash() {
    pkill -P $$
    ( yad \
    --no-buttons \
    --on-top \
    --undecorated \
    --skip-taskbar \
    --no-focus \
    --center \
    --text-align=center \
    --image="/home/rory/Desktop/asus-ROG-profile-linux/assets/$1.png" \
    --sticky \
    --timeout=1 \
    --splash ) & 
}

if [[ $1 == "--quiet" || $2 == "--quiet" ]]; then
	asusctl profile -PQuiet && notify-send -pe "$(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
elif [[ $1 == "--balanced" || $2 == "--balanced" ]]; then
	asusctl profile -PBalanced && notify-send -pe "$(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
elif [[ $1 == "--performance" || $2 == "--performance" ]]; then
	asusctl profile -PPerformance && notify-send -pe "$(asusctl profile -p)" "Default fan mode loaded." > /tmp/notifyID
elif [[ $1 == "-h" ]]; then
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
	echo "    -n  --notify      display old notifications when switching"
	echo "    "
	echo "    --quiet	       Starts the script with setting the fan mode to Quiet by default."
	echo "    --balanced       Starts the script with setting the fan mode to Balanced by default."
	echo "    --performance    Starts the script with setting the fan mode to Performance by default."
	echo "    "
	exit
else
	notify-send -pe "$(asusctl profile -p)" "Fan mode changer listening..."> /tmp/notifyID
fi

if [[ $1 == "--notify" || $2 == "--notify" || $1 == "-n" || $2 == "-n" ]]; then
	while true; do
		if [[ $(acpi_listen -c 1) = " 0B3CBB35-E3C2- 000000ff 00000000" ]]; then
			if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
				asusctl profile -PQuiet && notify-send --urgency=critical -rp $(head /tmp/notifyID) "$(asusctl profile -p)" "Fan mode changed to Quiet." > /tmp/notifyID
				notify $?
			elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
				asusctl profile -PBalanced && notify-send --urgency=critical -rp $(head /tmp/notifyID) "$(asusctl profile -p)" "Fan mode changed to Balanced." > /tmp/notifyID
				notify $?
			elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
				asusctl profile -PPerformance && notify-send --urgency=critical -rp $(head /tmp/notifyID) "$(asusctl profile -p)" "Fan mode changed to Performance." > /tmp/notifyID
				notify $?
			fi
		fi
	done
else 
    while true; do
		if [[ $(acpi_listen -c 1) = " 0B3CBB35-E3C2- 000000ff 00000000" ]]; then
			if [[ $(powerprofilesctl list | grep '*') = "* power-saver:" ]]; then
				asusctl profile -PQuiet
                splash 0
			elif [[ $(powerprofilesctl list | grep '*') = "* balanced:" ]]; then
				asusctl profile -PBalanced
                splash 1
			elif [[ $(powerprofilesctl list | grep '*') = "* performance:" ]]; then
				asusctl profile -PPerformance
                splash 2
			fi
		fi
	done
fi
