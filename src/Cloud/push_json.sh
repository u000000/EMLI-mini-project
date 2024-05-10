#!/bin/bash

# Specify the folder containing JSON files
folder=$1

# Navigate to the folder or exit if not found
cd "$folder" || exit

# Add all JSON files to the staging area
git add *.json

# Check if there are any JSON files to commit
if [ -n "$(git diff --cached --name-only -- '*.json')" ]; then
    # Commit with a default message
    git commit -m "Automated commit: $(date) - Updated JSON files"
    
    # Push changes to the remote repository
    git push
else
    echo "No JSON files to commit."
fi