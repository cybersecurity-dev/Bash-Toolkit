#!/bin/bash
echo "Count Files in Directory"
echo "============================"
while true; do
  echo $(ls -1 | wc -l)
  sleep 59
done
echo "============================"
read -p "Press any key to continue..."
