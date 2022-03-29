#!/bin/bash

function conTest() {
	if [[ -z $1 ]] || [[ -z $2 ]]; then
		echo "Bad function call"
		exit 1
	fi

	ping -c 1 $1 > /dev/null &> /dev/null

	if [[ $? -gt 0 ]]; then
		echo "$2 unreachable"
	else
		echo "$2 OK"
	fi
}

conTest 1.1.1.1 "Cloudflare DNS (IP)"
conTest one.one.one.one "Cloudflare DNS"
conTest google.com "Google"
conTest discord.com "Discord"
conTest mc.hypixel.net "Hypixel"
conTest hiperdex.com "Hiperdex"
