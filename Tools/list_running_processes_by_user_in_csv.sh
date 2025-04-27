#!/bin/bash

# Output CSV header
echo "process_owner,process_name,process_path,uptime_of_process"

# Use ps to get processes, sort by user and process name (case-insensitive)
ps -eo user,comm,fname,etimes | sort -f -k1,1 -k2,2 | awk -F' ' '
{
    user = $1
    process_name = $2
    process_path = $3
    uptime = $4
    # Escape commas and quotes in fields to make CSV-safe
    gsub(/"/, "\"\"", user)
    gsub(/"/, "\"\"", process_name)
    gsub(/"/, "\"\"", process_path)
    # Print CSV line
    printf "\"%s\",\"%s\",\"%s\",%s\n", user, process_name, process_path, uptime
}'