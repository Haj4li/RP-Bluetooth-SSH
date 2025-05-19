# Raspberry Pi Bluetooth SSH

This bash script automates the setup of a **Bluetooth Personal Area Network (PAN)** on Raspberry Pi (or any Linux system with Bluetooth ). It configures a Bluetooth interface to act as a Network Access Point (NAP), enabling IP-based communication over Bluetooth.

## 🔧 Features

- Kills any conflicting Bluetooth processes (`bt-agent`, `bt-network`).
- Restarts the Bluetooth service.
- Starts a Bluetooth NAP server.
- Sets up a network bridge (`pan0`) and assigns a static IP.
- Configures and restarts `dnsmasq` to serve DHCP over the PAN.
- Enables IP forwarding and NAT via iptables.
- You can connect your phone to Raspberry Pi over Bluetooth and establish SSH connection with provided pan0 IP (in Termux for example)

---

## 🧾 Configuration

These values can be modified in the script to fit your setup:

```bash
BT_INTERFACE="hci0"
BRIDGE_INTERFACE="pan0"
STATIC_IP="192.168.50.1"
DHCP_RANGE_START="192.168.50.10"
DHCP_RANGE_END="192.168.50.50"
DNSMASQ_CONF="/etc/dnsmasq.d/bt-pan.conf"
```

---

## 🚀 Usage

> ⚠️ **Requires root privileges.**

1. Ensure Bluetooth and dnsmasq are installed.
2. Save the script and make it executable:
    ```bash
    chmod +x bt-ssh.sh
    ```
3. Run the script:
    ```bash
    sudo ./bt-ssh.sh
    ```

Your system will now broadcast a Bluetooth PAN using interface `pan0`, with IP range `192.168.50.10-50`.

---

## 📋 Notes

- Ensure your Bluetooth adapter supports PAN.
- Connected devices should automatically receive an IP via DHCP and have internet access if `wlan0` is your internet-facing interface.

---

## 🧼 Cleanup

To undo the changes:
```bash
sudo pkill -f bt-agent
sudo pkill -f bt-network
sudo ip link set pan0 down
sudo brctl delbr pan0
sudo rm -f /etc/dnsmasq.d/bt-pan.conf
sudo systemctl restart dnsmasq
```

---

## 🛠 Troubleshooting

- If devices don’t get an IP, check `dnsmasq` logs.
- Ensure `bluetooth.service` is active: `sudo systemctl status bluetooth`
- Interface `wlan0` might differ on your system (`ip a` to confirm).
- If you have troubles connecting to the device,  try to connect manually then run the script (add your device as a trusted device)

---

## 📜 License

MIT License — feel free to modify, improve, and profit.
