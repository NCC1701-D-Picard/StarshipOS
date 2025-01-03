#!/bin/bash

# Function to clean unnecessary files and directories recursively
clean_recursively() {
    local current_dir="$1"
    echo "Cleaning: $current_dir"

    # Remove `.git` directories
    if [ -d "$current_dir/.git" ]; then
        echo "Removing .git directory: $current_dir/.git"
        rm -rf "$current_dir/.git"
    fi

    # Remove `.idea` directories
    if [ -d "$current_dir/.idea" ]; then
        echo "Removing .idea directory: $current_dir/.idea"
        rm -rf "$current_dir/.idea"
    fi

    # Remove IntelliJ `.iml` files
    find "$current_dir" -maxdepth 1 -type f -name "*.iml" -exec echo "Removing IntelliJ .iml file: {}" \; -exec rm -f {} \;

    # Remove Maven wrapper and build directories
    if [ -d "$current_dir/.mvn" ]; then
        echo "Removing .mvn directory: $current_dir/.mvn"
        rm -rf "$current_dir/.mvn"
    fi

    if [ -f "$current_dir/mvnw" ]; then
        echo "Removing Maven wrapper script: $current_dir/mvnw"
        rm -f "$current_dir/mvnw"
    fi

    if [ -f "$current_dir/mvnw.cmd" ]; then
        echo "Removing Maven wrapper script: $current_dir/mvnw.cmd"
        rm -f "$current_dir/mvnw.cmd"
    fi

    # Remove Maven `target` build directories
    if [ -d "$current_dir/target" ]; then
        echo "Removing Maven target directory: $current_dir/target"
        rm -rf "$current_dir/target"
    fi

    # Remove log files
    find "$current_dir" -maxdepth 1 -type f -name "*.log" -exec echo "Removing log file: {}" \; -exec rm -f {} \;

    # Remove OS metadata files
    find "$current_dir" -maxdepth 1 -type f -name ".DS_Store" -exec echo "Removing .DS_Store file: {}" \; -exec rm -f {} \;
    find "$current_dir" -maxdepth 1 -type f -name "Thumbs.db" -exec echo "Removing Thumbs.db file: {}" \; -exec rm -f {} \;

    # Recursively process all subdirectories
    for subdir in "$current_dir"/*; do
        if [ -d "$subdir" ]; then
            clean_recursively "$subdir" # Recursively clean subdirectories.
        fi
    done
}

# Main script entry point
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 /path/to/project_directory"
    exit 1
fi

project_dir="$1"

if [ -d "$project_dir" ]; then
    clean_recursively "$project_dir"
    echo "Cleanup complete for: $project_dir"
else
    echo "Error: $project_dir is not a valid directory."
    exit 1
fi
