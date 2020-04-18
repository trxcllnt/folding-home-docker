#! /usr/bin/env bash

set -e

cd $(dirname $(realpath "$0"))

select_option() {
    MSG="$1"
    DEFAULT="$2"
    SELECTION=""
    read -p "$MSG (default=$DEFAULT): " SELECTION </dev/tty
    if [ "$SELECTION" = "" ]; then
        SELECTION="$DEFAULT";
    fi
    echo "$SELECTION"
}

echo "NVIDIA's team ID is 58812"
echo "Find a full list of teams at https://stats.foldingathome.org/teams"
echo ""

GPUS_XML=""
FAH_TEAM=$(select_option "Enter optional folding@home team ID" "")
FAH_USER=$(select_option "Enter optional folding@home username" "anon")
FAH_PASSWORD=$(select_option "Enter optional folding@home password" "")
FAH_LOG_LEVEL=$(select_option "Enter optional folding@home log level (range 1=none, 5=verbose)" "5")

if [[ -n "$(which nvidia-smi)" ]]; then
    NUM_GPUS="$(nvidia-smi --list-gpus | wc -l)"
else
    NUM_GPUS="$(lspci | grep -E "(NVIDIA|AMD)" | grep "VGA" | wc -l)"
fi

if [[ $NUM_GPUS != "0" ]]; then
    GPUS=$(select_option "\
Which GPUs do you want to use?
Enter \"all\", \"none\", or any of these ids: \"$(echo `seq 0 $((NUM_GPUS-1))`)\"" "all")
    # expand "all" to sequence 0 ... $NUM_GPUS
    [[ "$GPUS" == "all" ]] && GPUS="$(seq 0 $((NUM_GPUS-1)))"
    if [[ "$GPUS" != "none" ]]; then
        # replace commas with spaces if user input commas
        GPUS="$(echo $GPUS | tr ',' ' ')"
        GPUS_XML="<gpu v='true'/>"
        for i in $GPUS; do
            GPUS_XML=$(echo -e "$GPUS_XML\n    <slot id='$i' type='GPU'/>");
        done;
    fi
fi

echo "<config>
    <power v='full'/>
    <team v='$FAH_TEAM'/>
    <user v='$FAH_USER'/>
    <verbosity v='$FAH_LOG_LEVEL'/>
    $GPUS_XML
</config>" | tee ./config.xml;

echo "$FAH_PASSWORD" > .fah-password

echo "Wrote $PWD/config.xml"
