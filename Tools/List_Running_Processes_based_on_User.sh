#!/bin/bash

# Display header
echo "USER       PID    PROCESS"
echo "-----------------------------"

# Use ps to get processes, sort by user and process name (case-insensitive), and group
ps -eo user,pid,comm | sort -f -k1,1 -k3,3 | awk '
{
    if ($1 != prev_user && NR > 1) {
        print "-----------------------------"
    }
    printf "%-10s %-6s %s\n", $1, $2, $3
    prev_user = $1
}'