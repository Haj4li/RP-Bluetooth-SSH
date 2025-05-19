#!/bin/bash

# === CONFIG ===
BT_INTERFACE="hci0"
BRIDGE_INTERFACE="pan0"
STATIC_IP="192.168.50.1"
DHCP_RANGE_START="192.168.50.10"
DHCP_RANGE_END="192.168.50.50"
DNSMASQ_CONF="/etc/dnsmasq.d/bt-pan.conf"

echo "[+] Killing old Bluetooth processes..."
sudo pkill -f bt-agent
sudo pkill -f bt-network

echo "[+] Restarting bluetooth service..."
sudo systemctl restart bluetooth

echo "[+] Starting bt-agent..."
sudo bt-agent -c NoInputNoOutput &

sleep 2

echo "[+] Starting bt-network NAP server..."
sudo bt-network -s nap $BRIDGE_INTERFACE &

sudo brctl addbr pan0
sudo ip link set pan0 up

sleep 2

echo "[+] Waiting for interface $BRIDGE_INTERFACE..."
for i in {1..10}; do
    if ip link show "$BRIDGE_INTERFACE" > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ! ip link show "$BRIDGE_INTERFACE" > /dev/null 2>&1; then
    echo "[-] Failed to find $BRIDGE_INTERFACE interface. Exiting."
    exit 1
fi

echo "[+] Assigning static IP to $BRIDGE_INTERFACE..."
sudo ip addr flush dev "$BRIDGE_INTERFACE"
sudo ip addr add "$STATIC_IP/24" dev "$BRIDGE_INTERFACE"
sudo ip link set "$BRIDGE_INTERFACE" up

echo "[+] Creating dnsmasq config..."
echo -e "interface=$BRIDGE_INTERFACE\ndhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,12h" | sudo tee "$DNSMASQ_CONF" > /dev/null

echo "[+] Restarting dnsmasq..."
sudo systemctl restart dnsmasq

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

echo "[+] Bluetooth PAN ready on $STATIC_IP"
