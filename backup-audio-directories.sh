#!/bin/bash
set -eou pipefail

# TODO try rynsc and see if its better for this. Progress bars would be nice.
# TODO provide time taken to run this entire thing

EXTERNAL_HARD_DRIVE_NAME="breezy"
DESTINATION_PARENT_FOLDER_NAME="m1-macbook-backups"

DEBUG_MODE=0
if [ $DEBUG_MODE -gt 0 ]; then
    TODAYS_DATE="2006-06-01"
else
    TODAYS_DATE=$(date +"%Y-%m-%d")
fi
DESTINATION_FOLDER_NAME="/Volumes/$EXTERNAL_HARD_DRIVE_NAME/$DESTINATION_PARENT_FOLDER_NAME/$TODAYS_DATE"

# Jidoka steps
# Check the destination drive is available: /Volumes/breezy/
if [ ! -d "/Volumes/$EXTERNAL_HARD_DRIVE_NAME" ]; then
    echo "External hard, $EXTERNAL_HARD_DRIVE_NAME, not found"
    exit 1
fi

# Check the target directory exists: /Volumes/breezy/m1-macbook-backups/
if [ ! -d "/Volumes/$EXTERNAL_HARD_DRIVE_NAME/$DESTINATION_PARENT_FOLDER_NAME" ]; then
    echo "Parent directory for backups not found, $DESTINATION_PARENT_FOLDER_NAME, not found"
    exit 1
fi

command -v pgrep >/dev/null

# If Logic Pro X already running, throw error. E.g., don't try and read/write files are in-use.
# If pgrep exits 0, one or more processes were found.
if [ -n "$(pgrep Logic)" ]; then
    echo "Logic Pro is currently running. Files will not be backed up."
    exit 1
fi
# make a new folder with today's date formatted 2024-08-30
mkdir "$DESTINATION_FOLDER_NAME"
echo "New backup folder created"

# Copy all the known critical Logic Pro configuration files
cp -r "$HOME/Music/Audio Music Apps/" "$DESTINATION_FOLDER_NAME/Audio Music Apps"
echo "Finished backing up configuration"

# Copy all VST3, VST (legacy), and Audio Unit (AU) plugins
# AU
cp -r "/Library/Audio/Plug-Ins/Components" "$DESTINATION_FOLDER_NAME/Components"
# VST3
cp -r "/Library/Audio/Plug-Ins/VST3" "$DESTINATION_FOLDER_NAME/VST3"
# VST (legacy)
cp -r "/Library/Audio/Plug-Ins/VST" "$DESTINATION_FOLDER_NAME/VST"
echo "Finished backing up plugins"

# Copy the entire ~/Music/Logic/ directory which includes all Logic Pro projects
cp -r "$HOME/Music/Logic" "$DESTINATION_FOLDER_NAME"
echo "Finished backing up projects"

echo "✨ Backup complete 💪🏽 "
echo "Files written to $DESTINATION_FOLDER_NAME"
