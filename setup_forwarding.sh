#!/usr/bin/env bash

set -e

# Check if we're on Debian or a Debian-based system
if [ -f /etc/debian_version ] || grep -q "Debian" /etc/os-release 2>/dev/null; then
    echo "System appears to be Debian or Debian-based"
else
    echo "Warning: This doesn't appear to be Debian. The instructions were specifically for Debian systems."
    echo "Detected system:"
    cat /etc/os-release 2>/dev/null || echo "Cannot determine OS"

    read -p "Would you like to proceed anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
	    echo "Operation cancelled."
	    exit 1
    fi
fi

# Usage: ./setup_forwarding.sh <PUBLIC_INTERFACE> <VPN_INTERFACE> <DESTINATION_IP>

if [ $# -ne 3 ]; then
    echo "Usage: $0 <PUBLIC_INTERFACE> <VPN_INTERFACE> <DESTINATION_IP>"
    echo "Example: $0 eth0 wt0 100.64.0.2"
    exit 1
fi

PUBLIC_IF="$1"
VPN_IF="$2"
DEST_IP="$3"

echo "This will add persistent routes to forward all incoming traffic on the specified interface."
echo ""
echo "Forward traffic from interface: $PUBLIC_IF"
echo "To the IP: $DEST_IP"
echo "On interface: $VPN_IF"
echo ""
read -p "Would you like to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

echo "Enabling IP forwarding..."
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl --system

echo "Verifying IP forwarding:"
# Check if IP forwarding is enabled in the kernel
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -eq 1 ]; then
    echo "Success: IP forwarding is enabled in the kernel"
else
    echo "Error: IP forwarding is not enabled. Please check the configuration."
    exit 1
fi

echo "Setting up iptables rules..."
sudo iptables -t nat -A PREROUTING -i "$PUBLIC_IF" -j DNAT --to-destination "$DEST_IP"
sudo iptables -t nat -A POSTROUTING -o "$VPN_IF" -j MASQUERADE
sudo iptables -A FORWARD -i "$PUBLIC_IF" -o "$VPN_IF" -j ACCEPT
sudo iptables -A FORWARD -i "$VPN_IF" -o "$PUBLIC_IF" -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Installing iptables-persistent..."
sudo apt update
sudo apt install -y iptables-persistent

echo "Saving rules persistently..."
sudo netfilter-persistent save

echo "Setup complete! Rules have been configured and saved."
