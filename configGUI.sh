#!/bin/bash

plug=$RANDOM
rogTmp="/tmp/rog_$plug.tmp"
fanTmp="/tmp/fan_$plug.tmp"

mkdir ~/.config/asusFanDriver/ 2> /dev/null
cd ~/.config/asusFanDriver/
rogCfg="./rog.cfg"
fanCfg="./fan.cfg"

touch $rogCfg
touch $fanCfg

userName=$(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f 1)


setCBValue() {
    options="$1"
    if [[ $1 != "" ]] ; then
        selection="$2"
        selectionFixed="^$2"
        output="${options/${selection}/${selectionFixed}}"
        echo
    else
        output=$options
    fi 
    echo $output
}

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

writeConfig() {
    # ROG Key/Value
    cat $rogTmp | awk '{ print "rogLEDStartup="$1 }' > $rogCfg
    cat $rogTmp | awk '{ print "rogCLRMode="$2 }' >> $rogCfg
    cat $rogTmp | awk '{ print "rogCLRSpeed="$3 }' >> $rogCfg
    cat $rogTmp | awk '{ print "rogPrimaryCLR="$4 }' >> $rogCfg
    cat $rogTmp | awk '{ print "rogSecondaryCLR="$5 }' >> $rogCfg
    
    # Fan
    cat $fanTmp | awk '{ print "rogDefaultFanMode="$1 }' > $fanCfg
    cat $fanTmp | awk '{ print "rogFanDisplayMode="$2 }' >> $fanCfg
}

readConfig

# Fix Case Var
rogCLRMode=$(setCBValue "Static!Breathe!Pulse!Rainbow" "$rogCLRMode")
rogCLRSpeed=$(setCBValue "low!med!high" "$rogCLRSpeed")

rogDefaultFanMode=$(setCBValue "Saved!Quiet!Balanced!Performance" "$rogDefaultFanMode")
rogFanDisplayMode=$(setCBValue "None!Splash!Notifcation" "$rogFanDisplayMode")

    # LED
    (
        yad  --form --separator=" " --plug=$plug --tabnum=1\
        --field="<b>Keyboard Options</b>":LBL ""\
        --field="Change on Startup":SW "$rogLEDStartup"\
        --field="LED Color Mode":CB $rogCLRMode \
        --field="LED Color Speed":CB $rogCLRSpeed\ \
        --field="LED Primary Color":CLR "$rogPrimaryCLR"\
        --field="LED Secondary Color":CLR "$rogSecondaryCLR"\
        >$rogTmp
    )&\
    # Fan
    (
        yad --form --separator=" " --plug=$plug --tabnum=2\
        --field="<b>Fan Options</b>":LBL ""\
        --field="Default Profile Mode":CB $rogDefaultFanMode \
        --field="Display Change Mode":CB $rogFanDisplayMode \
        >$fanTmp
    )&\
    #draw UI
    (
        yad --notebook --window-icon=color-management --key=$plug --width=300 --title="$userName: $(hostname) Config"\
        --tab="Keyboard"\
        --tab="Fan"\
        --button="Apply"!!"Restarts the services to apply the changes now.":2\
        --button="Save"!!"Saves the config and exits but doesn't restart the services.":0\
        --button="Cancel"!!"Doesn't Save anything and exit.":1\
    )
    exitCode=$?
    
if [[ $exitCode -eq 0 ]] ; then
    writeConfig
elif [[ $exitCode -eq 2 ]] ; then
    killall -9 asusfan
    writeConfig
    readConfig
    if [[ $rogLEDStartup == "FALSE" ]] ; then
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
    (
        asusfan
    )&
    (
        asusfan-config
    )&
fi

rm $rogTmp
rm $fanTmp
