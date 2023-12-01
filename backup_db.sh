#!/bin/sh

PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PGPASSWORD=backup123
export PGPASSWORD
pathB=/test-nfs
dbUser=backadm
database=jira
host=10.224.98.3
backup_type=daily
daily_store=7

#backup
backup_dir="$pathB/$backup_type"
mkdir -p "$backup_dir"
backup_file="pgsql_$(date +%Y-%m-%d_%H-%M-%S).sql.gz"
backup_file_path="$backup_dir/$backup_file"

pg_dumpall -h $host -U $dbUser | gzip > $backup_file_path

  status=$?
  if [ $status -eq 0 ]; then
    echo "Backup $backup_file_path has been created."
  else
    echo "Can't create backup"
    return $status
  fi

#clean
# $1 - storrage_path
# $2 - backup_type
# $3 - numbers of files to store
clean_folder() {
  if [ ! -d "$1/$2" ]; then
    echo "There isn't $2 folder yet."
    return 0
  fi

  foldername="$(basename "$CURRENT_PATH")"
  # list of files sorted by time only for CURRENT FOLDER name
  files=$(ls -t "$1/$2/"pgsql_*"")
  count=$(echo "$files" | wc -l)

  if [ "$count" -gt "$3" ]; then
      echo "$files" | tail -n +$(($3 + 1)) | xargs rm -f
      echo "Removed $((count - $3)) files in $1/$2"
  else
      echo "No files to remove in $1/$2"
  fi
}

clean_folder "$pathB" "$backup_type" "$daily_store"

unset PGPASSWORD
