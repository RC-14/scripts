#!/bin/bash

ping -c 1 1.1.1.1 > /dev/null &> /dev/null && echo "Cloudflare DNS (IP) OK" || echo "Cloudflare DNS (IP) unreachable"
ping -c 1 one.one.one.one > /dev/null &> /dev/null && echo "Cloudflare DNS OK" || echo "Cloudflare DNS unreachable"
ping -c 1 google.com > /dev/null &> /dev/null && echo "Google OK" || echo "Google unreachable"
ping -c 1 discord.com > /dev/null &> /dev/null && echo "Discord OK" || echo "Discord unreachable"
ping -c 1 mc.hypixel.net > /dev/null &> /dev/null && echo "Hypixel OK" || echo "Hypixel unreachable"
ping -c 1 hiperdex.com > /dev/null &> /dev/null && echo "Hiperdex OK" || echo "Hiperdex unreachable"
