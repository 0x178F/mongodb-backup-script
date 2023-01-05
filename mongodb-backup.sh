#!/bin/bash

# Check if mongodump is installed?
if ! [ -x "$(command -v mongodump)" ]; then
  echo 'Mongodump is not installed. Installing now...'
  # install mongodump based on the system
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # install mongodump on macOS
    brew install mongodb/brew/mongodb-database-tools
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # install mongodump on Linux
    sudo apt-get update
    sudo apt-get install -y mongodb-org-tools
  else
    echo "Unsupported system"
    exit 1
  fi
fi

# MongoDB connection strings array
db_connections=(
  "mongodb://user:example@localhost:27017/example-database-one?authSource=admin&retryWrites=true&w=majority"
  "mongodb://user:example@localhost:27017/example-database-two?authSource=admin&retryWrites=true&w=majority"
)

# Current date and time
date_time=$(date +"%Y%m%d%H%M%S")

# parallel run
parallel_backup=true

#backup deletion time
delete_period=30 # 30 days

# Set backup path and log file path 
backup_folder="backups"
log_file="${backup_folder}/logs/backup.log"

# Check if log file exists, create if it does not
if [ ! -f "$log_file" ]; then
  mkdir -p "$(dirname "$log_file")"
  touch "$log_file"
fi

# Print message to log file
echo "Start time: $(date)" >> "$log_file"
echo "Database backup process started." >> "$log_file"

# Loop through each connection string
for connection in "${db_connections[@]}"; do
  # Extract database name from the connection string
  db_name=$(echo $connection | sed 's/.*\///' | sed 's/\?.*//') 

  # Create a backup directory for the database
  mkdir -p "$backup_folder/$db_name"


# Perform backup in parallel if $parallel_backup is set to "true", otherwise it performs backup sequentially
if [ "$parallel_backup" = "true" ]; then
  (mongodump --uri "$connection" --out "$backup_folder/$db_name/$date_time" && echo "Database backup operation completed successfully: $db_name" >> "$log_file" || echo "Error occurred: $db_name" >> "$log_file") &
else
  mongodump --uri "$connection" --out "$backup_folder/$db_name/$date_time"
  if [ $? -ne 0 ]; then
    # Print error message to log file
    echo "Error in database backup operation: $mongodump_output" >> "$log_file"
    echo "Error occurred: $db_name" >> "$log_file"
  else
    # Print success message to log file
    echo "Database backup operation completed successfully: $db_name" >> "$log_file"
  fi
fi
done

# Wait for all parallel tasks to finish
if [ "$parallel_backup" = "true" ]; then
  wait
fi

# Print message to log file
echo "Database backup process finished." >> "$log_file"
echo "End time: $(date)" >> "$log_file"

# Delete files older than 30 days. Duration can be set with delete_period
find $backup_folder -mtime +$delete_period -not -path '*/logs/*' -print0 | xargs -0 rm -f
# Find and delete invisible files and empty folders
find $backup_folder -type f -name ".*" -delete -o -type d -empty -depth -delete
