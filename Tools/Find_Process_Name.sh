#!/bin/bash

# Check if the path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

Path="$1"

# Check if the path exists
if [ ! -e "$Path" ]; then
  echo "Path '$Path' does not exist."
  exit 1
fi

# Resolve the path to its full, canonical form
FullPath=$(realpath "$Path")

echo "Checking processes using file/directory: $FullPath"

# Check if the path is a file or a directory
if [ -f "$FullPath" ]; then
  # Path is a file
  Processes=$(lsof "$FullPath" 2>/dev/null)
elif [ -d "$FullPath" ]; then
  # Path is a directory
  Processes=$(lsof +D "$FullPath" 2>/dev/null)
else
  echo "Path '$FullPath' is neither a file nor a directory."
  exit 1
fi

if [ -n "$Processes" ]; then
  echo "Processes using '$FullPath':"
  echo "$Processes" | awk 'NR>1 {print "Process ID: "$2", Name: "$1", Path: "$9}'
else
  echo "No processes found using '$FullPath'."
fi
#./Find_Process_Name.sh "path/to/your/file.txt"
#./Find_Process_Name.sh "path/to/your/directory"