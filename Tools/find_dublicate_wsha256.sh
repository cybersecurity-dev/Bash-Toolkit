echo "=== Checking Duplicate SHA256 Hashes ===" && \
find <file_dir> -mindepth 2 -maxdepth 2 -type f | \
  xargs sha256sum | \
  sort | \
  awk 'prev==$1 {print "DUPLICATE HASH: " $1 "\n  -> " prevfile "\n  -> " $2} {prev=$1; prevfile=$2}'
