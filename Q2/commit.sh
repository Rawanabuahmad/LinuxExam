#!/bin/bash

# Log file
LOG_FILE="commit.log"
CSV_FILE="bugs.csv"
echo "" > $LOG_FILE # Clear the log file

# Log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> "$LOG_FILE"
}

# Get the current Git branch
CURRENT_BRANCH=$(git branch --show-current)

log "Current branch: $CURRENT_BRANCH"

# Search for the row in bugs.csv that matches the current branch
ROW=$(grep "$CURRENT_BRANCH" "$CSV_FILE")

# If no matching row is found, exit with an error
if [ -z "$ROW" ]; then
    log "Error: No matching branch found in $CSV_FILE for branch $CURRENT_BRANCH"
    echo "Error: No matching branch found in $CSV_FILE for branch $CURRENT_BRANCH"
    exit 1
fi

log "Matching row found: $ROW"

# Extract values from the CSV
BUG_ID=$(echo "$ROW" | cut -d',' -f1)
DESCRIPTION=$(echo "$ROW" | cut -d',' -f2)
DEV_NAME=$(echo "$ROW" | cut -d',' -f4)
PRIORITY=$(echo "$ROW" | cut -d',' -f5)

# Generate the current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create the commit message
COMMIT_MESSAGE="$BUG_ID:$TIMESTAMP:$CURRENT_BRANCH:$DEV_NAME:$PRIORITY:$DESCRIPTION"

# If a parameter is provided, treat it as "Developer Description"
if [ "$#" -eq 1 ]; then
    DEV_DESCRIPTION=$1
    COMMIT_MESSAGE="$COMMIT_MESSAGE:$DEV_DESCRIPTION"
    log "Developer description provided: $DEV_DESCRIPTION"
else
    log "No developer description provided."
fi

# Log the commit message
log "Generated commit message: $COMMIT_MESSAGE"

# Perform Git operations
log "Committing changes with message: $COMMIT_MESSAGE"
git commit -am "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
    log "Error: Failed to commit changes."
    echo "Error: Failed to commit changes."
    exit 1
fi

# Push the changes to GitHub
log "Pushing changes to GitHub"
git push origin "$CURRENT_BRANCH"

if [ $? -ne 0 ]; then
    log "Error: Failed to push changes to GitHub."
    echo "Error: Failed to push changes to GitHub."
    exit 1
fi

log "Commit and push completed successfully."
echo "Commit and push completed successfully."
