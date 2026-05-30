find ./folder_name/ -mindepth 2 -maxdepth 2 -type f | \
  xargs sha256sum | \
  sort | \
  awk '{ hash=$1; file=$2 }
       seen[hash]++ == 0 { first[hash]=file; next }
       { print "KEEPING:  " first[hash] "\nDELETING: " file "\n" }' | \
  tee ./duplicate_delete_report.txt | \
  grep "^DELETING:" | \
  awk '{print $2}' | \
  xargs -I {} rm {}
