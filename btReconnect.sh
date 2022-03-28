#! /bin/bash

if [[ -z $1 ]]; then
	echo "Usage: btReconnect <Bluetooth MAC adress>"
	exit 1
fi

bluetoothctl power off
bluetoothctl power on
bluetoothctl connect $1

