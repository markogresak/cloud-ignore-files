#!/bin/bash
#
# v1.0.0
#
# Usage:
#  - Call script to register sync script with launchd.
#  - Call with `--no-logs` to disable logging.
#  - Call with `--uninstall` or `--remove` to unregister from launchd and clean up files.

# Adjust the paths to match your system (do not end the path with /).
# Path to local (working) projects folder
local_path="${HOME}/LocalDocs/Projects"

# Path to cloud projects folder (node_modules, etc. are omitted).
#
# Note: if you're using iCloud on a system before Sierra, the Documents folder
# can be found at "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
cloud_path="${HOME}/Documents/Projects"

# Comma-separated list of files to ignore.
# Example: "node_modules,*.log" -> ignore all paths containing `node_modules` and any files ending with `*.log`.
# For more details see: http://www.cis.upenn.edu/~bcpierce/unison/download/releases/stable/unison-manual.html#ignore
ignore_files="node_modules,bower_components,*.log,.DS_Store"

# If you want, change log destination here (irellevant with --no-logs flag).
log_file="/var/log/${label}.out.log"
err_file="/var/log/${label}.err.log"

##########################################################################
# No need to modify the code below, unless you know what you're doing :D #
##########################################################################

# Path to script and launchd config.
label="com.markogresak.projects.CloudSyncIgnore"
script_path="/usr/local/bin/${label}.sh"
plist_path="${HOME}/Library/LaunchAgents/${label}.plist"

# If config already exists, unload it before updating it.
if [ -f $plist_path ]; then
  launchctl unload $plist_path
fi

if [[ "$1" == "--uninstall" || "$1" == "--remove" ]]; then
  rm -f $script_path $plist_path
  if [ -f $log_file ] || [ -f $err_file ]; then
    echo "The script will attempt to remove log files. This requires sudo access, so the shell will ask you for password."
    sudo rm -f $log_file $err_file
  fi
  echo "Sync script successfully removed. Thanks for giving it a chance. If you have any suggestions for improvement, please let me know by submitting an issue."
  exit
fi

# Check for unison command and fail if not found.
if ! command -v unison >/dev/null 2>&1; then
  echo "Command 'unison' not found. Install it (brew install unison) and try this script again."
  exit 1
fi

# If `--no-logs` flag is used, use /dev/null as stdout and stderr.
if [[ "$1" == "--no-logs" ]]; then
  log_file="/dev/null"
  err_file="/dev/null"
else
  echo "The script will attempt to create log files. This requires sudo access, so the shell will ask you for password."

  # Create/clear log files (requires sudo to allow modifying files in /var/log) and fix log file permissions.
  sudo sh -c 'echo "" > $0' "$log_file"
  sudo sh -c 'echo "" > $0' "$err_file"
  sudo chown `whoami` "$log_file" "$err_file"
  echo -e "Log files were successfully created.\n"
fi

# Create actual files based of .template files.
sed "s|{{LOCAL_PATH}}|${local_path}|;
     s|{{CLOUD_PATH}}|${cloud_path}|;
     s|{{SCRIPT_PATH}}|${script_path}|;
     s|{{LABEL}}|${label}|;
     s|{{LOG_FILE}}|${log_file}|;
     s|{{ERR_FILE}}|${err_file}|" plist.template > $plist_path
sed "s|{{UNISON_PATH}}|$(which unison)|;
     s|{{IGNORE_FILES}}|${ignore_files}|;
     s|{{LOCAL_PATH}}|${local_path}|;
     s|{{CLOUD_PATH}}|${cloud_path}|;" script.template > $script_path

# Load launchd config.
launchctl load $plist_path

echo "Sync script added. It will be triggered any time any of files inside local or iCloud project folder changes."
echo "I hope this script will help make your life a little easier :)"
