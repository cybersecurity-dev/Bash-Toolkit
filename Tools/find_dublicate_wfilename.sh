find <file_dir> -mindepth 2 -maxdepth 2 -type f | \
  xargs -I {} basename {} | \
  sort | uniq -d | \
  while read fname; do
    echo "DUPLICATE: $fname found in:"
    find /test -mindepth 2 -maxdepth 2 -name "$fname" | sed 's/^/  -> /'
  done
