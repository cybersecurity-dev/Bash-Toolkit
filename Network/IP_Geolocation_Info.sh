#!/bin/bash

# Send a curl request to ipinfo.io and capture the response, including headers
response=$(curl -s -i ipinfo.io)

# Extract the HTTP status code
status_code=$(echo "$response" | head -n 1 | awk '{print $2}')

# Extract the status description
status_description=$(echo "$response" | head -n 1 | cut -d ' ' -f 3-)

# Check if the request was successful (status code 200)
if [[ "$status_code" != "200" ]]; then
  echo "Error: HTTP request failed with status code $status_code - $status_description"
  exit 1
fi

# Extract the JSON content from the response (remove headers)
json_content=$(echo "$response" | sed '1,/^$/d')


# Extract the desired fields using jq
ip=$(echo "$json_content" | jq -r '.ip')
city=$(echo "$json_content" | jq -r '.city')
region=$(echo "$json_content" | jq -r '.region')
country=$(echo "$json_content" | jq -r '.country')
loc=$(echo "$json_content" | jq -r '.loc')
org=$(echo "$json_content" | jq -r '.org')
postal=$(echo "$json_content" | jq -r '.postal')

# Print the header row of the CSV file, only if the file doesn't exist
if [ ! -f ipinfo.csv ]; then
  echo "status_code,status_description,ip,city,region,country,loc,org,postal" > ipinfo.csv
fi

# Print the data row in CSV format, appending to the file
echo "$status_code,$status_description,$ip,$city,$region,$country,$loc,$org,$postal" >> ipinfo.csv

echo "Data saved to ipinfo.csv"

cat ipinfo.csv