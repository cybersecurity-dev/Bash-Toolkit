#!/bin/bash
echo "Restart network."
echo "============================"
sudo dhclient -r
sudo dhclient
sudo ip -s -s neigh flush all
sudo systemctl restart nmb
sudo systemctl restart smb
sudo systemctl restart network-manager
sudo systemctl restart networking
sudo systemctl restart systemd-resolved
echo "============================"
read -p "Press any key to continue..."