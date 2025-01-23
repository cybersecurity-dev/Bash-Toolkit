#!/bin/bash

# Run an osquery query to get system information
system_info=$(osqueryi --json "SELECT hostname, cpu_brand, physical_memory FROM system_info;")

# Check if the query was successful
if [[ $? -eq 0 ]]; then
  # Parse the JSON output
  hostname=$(echo "$system_info" | jq -r '.[0].hostname')
  cpu_brand=$(echo "$system_info" | jq -r '.[0].cpu_brand')
  memory=$(echo "$system_info" | jq -r '.[0].physical_memory')

  # Print the system information
  echo "Hostname: $hostname"
  echo "CPU Brand: $cpu_brand"
  echo "Memory: $(($memory / (1024 * 1024 * 1024))) GB"
else
  echo "Error running osquery query"
fi

# Run an osquery query to get process information
process_info=$(osqueryi --json "SELECT name, pid, cmdline FROM processes LIMIT 5;")

# Check if the query was successful
if [[ $? -eq 0 ]]; then
  # Print the process information
  echo "\nFirst 5 Processes:"
  echo "$process_info" | jq -r '.[] | "Name: " + .name + ", PID: " + (.pid | tostring) + ", Command: " + .cmdline'
else
  echo "Error running osquery query"
fi

# Example of using osquery to check for specific software
software_check=$(osqueryi --json "SELECT name, version FROM programs WHERE name = 'Google Chrome';")
if [[ $? -eq 0 ]]; then
    chrome_version=$(echo "$software_check" | jq -r '.[0].version')
    if [[ -n "$chrome_version" ]]; then
        echo "\nGoogle Chrome is installed. Version: $chrome_version"
    else
        echo "\nGoogle Chrome is not installed."
    fi
else
  echo "Error running osquery query"
fi
