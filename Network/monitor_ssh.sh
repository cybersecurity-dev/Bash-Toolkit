#!/bin/bash

# Function to display an alert
alert() {
  if command -v notify-send &> /dev/null; then
    notify-send "New SSH Connection" "$1"
  elif command -v osascript &> /dev/null; then
    osascript -e "display notification \"$1\" with title \"New SSH Connection\""
  else
    echo -e "\a$1"
  fi
}

# Get the initial list of SSH connections
initial_connections=$(ss -tnp | grep sshd)

while true; do
  # Get the current list of SSH connections
  current_connections=$(ss -tnp | grep sshd)

  # Compare the current list with the initial list to find new connections
  new_connections=$(comm -13 <(echo "$initial_connections") <(echo "$current_connections"))

  if [ -n "$new_connections" ]; then
    alert "New SSH connection detected: $new_connections"
    initial_connections="$current_connections"
  fi

  sleep 1
done