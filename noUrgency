#!/bin/bash
# Source: https://github.com/skontar/Utility/blob/master/scripts/start-apps

for win in $(wmctrl -l | awk -F' ' '{print $1}'); do
    wmctrl -i -r $win -b remove,demands_attention
done
