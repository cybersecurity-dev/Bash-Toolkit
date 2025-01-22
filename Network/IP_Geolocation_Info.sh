#!/bin/bash

# Send a curl request to ipinfo.io and capture the response
response=$(curl -s ipinfo.io)

# Check the HTTP status code
status_code=$(curl -s -w "%{http_code}" ipinfo.io -o /dev/null)

if [[ "$status_code" != "200" ]]; then
  echo "Error: HTTP request failed with status code $status_code"
  exit 1 # Exit with an error code
fi

# Extract the desired fields using jq
ip=$(echo "$response" | jq -r '.ip')
city=$(echo "$response" | jq -r '.city')
region=$(echo "$response" | jq -r '.region')
country=$(echo "$response" | jq -r '.country')
loc=$(echo "$response" | jq -r '.loc')
org=$(echo "$response" | jq -r '.org')
postal=$(echo "$response" | jq -r '.postal')

# Print the header row of the CSV file, only if the file doesn't exist
if [ ! -f ipinfo.csv ]; then
  echo "ip,city,region,country,loc,org,postal" > ipinfo.csv
fi

# Print the data row in CSV format, appending to the file
echo "$ip,$city,$region,$country,$loc,$org,$postal" >> ipinfo.csv

echo "Data saved to ipinfo.csv"

cat ipinfo.csv