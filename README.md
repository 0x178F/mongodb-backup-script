# MongoDB Backup Script

This script allows you to automate the process of backing up your MongoDB databases. It uses the mongodump command to create a binary export of your databases, which can be used to restore the databases to a previous state.

## Requirements

**mongodump** must be installed on the machine running this script. If it is not installed, the script will try to install it using brew or apt-get depending on your operating system.
A MongoDB connection string is required for each database that you want to back up. These connection strings should be added to the db_connections array in the script.

## Configuration

- The _delete_period_ variable determines how long backups should be kept before being deleted. The default is 30 days.
- The _backup_folder_ variable determines where the backups will be stored. The default is a folder called "backups".
- The _log_file_ variable determines the location of the log file, which will contain information about the backup process.

## Usage

1-) Download and make this script executable in a folder.

```ssh
git clone https://github.com/0x178F/mongodb-backup-script.git
cd mongodb-backup-script
chmod +x mongodb-backup.sh
```

2-) Edit the mongodb-backup.sh script and add the MongoDB connection strings.

```ssh
db_connections=(
  "mongodb://user:example@localhost:27017/example-database-one?authSource=admin&retryWrites=true&w=majority"
  "mongodb://user:example@localhost:27017/example-database-two?authSource=admin&retryWrites=true&w=majority"
)
```

3-) You can run the script by typing "./mongodb-backup.sh" in your terminal. If you want to run it periodically, you can use Cron on Unix systems.

## Features

- MongoDB Command Line Tools (mongodump) is checked for installation. If it is not installed, the script will try to install it using brew or apt-get depending on your operating system.
- A log file is created to record the process.
- Backups are created for the specified MongoDB connection strings.
- The script will create a new folder for each database that is backed up, inside the backup_folder. The name of the folder will be the same as the name of the database.
- The backups are created with the current date and time as the name, in the format YYYYMMDDHHMMSS.
- The script will delete files and empty directories older than the number of days specified in _delete_period_. This is to keep the _backup_folder_ from filling up with old backups.

## Note

- This script is tested on macOS and Linux systems. If you are using a different system, you may need to modify the commands for installing mongodump.
- Make sure that the user running the script has the necessary permissions to create and delete files and folders in the specified backup folder.
