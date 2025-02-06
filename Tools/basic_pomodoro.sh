#!/bin/bash

# Function to display an alert
alert() {
  if command -v notify-send &> /dev/null; then
    notify-send "$1"
  elif command -v osascript &> /dev/null; then
    osascript -e "display notification \"$1\" with title \"Pomodoro Timer\""
  else
    echo -e "\a$1"
  fi
}

while true; do
  # Work period
  #echo "Work for 50 minutes."
  alert "Work for 50 minutes."
  sleep 3000 # 50 minutes in seconds

  # Break period
  #echo "Take a 10-minute break."
  alert "Take a 10-minute break."
  sleep 600 # 10 minutes in seconds
done