#!/bin/bash

# Uncomment the following lines to prompt for the git repository path
echo "Type pwd in a new shell to print the full path of the current working directory to copy paste here"
echo "Please enter the path to your final capstone repository:"
read git_repo_path

# Check if the first argument is -test and set the test variable accordingly
if [ "$1" = "-test" ]; then
    test=true
    echo "\033[1m\033[0;33m***RUNNING IN TEST MODE. NO FILES WILL BE COPIED***\033[0m"
else
    test=false
fi

# Initialize a flag to check if all files/directories are present
all_present=true

# Check each file/directory and update its status
check_directory() {
    if [ ! -d "$1" ] && [ ! -f "$1" ]; then
        echo "\033[0;31m$2 is not present\033[0m"
        all_present=false
    else 
        echo "\033[0;34m✔️ Found $1\033[0m"
    fi
}

# Call the function for each directory or file
check_directory "$git_repo_path/java" "java directory"
check_directory "$git_repo_path/vue" "vue directory"
check_directory "$git_repo_path/vue/vite.config.js" "vite.config.js"
check_directory "$git_repo_path/vue/package.json" "package.json" 
check_directory "$git_repo_path/java/src/main/resources/application.properties" "application.properties" 
check_directory "$git_repo_path/java/database" "database directory"
check_directory "$git_repo_path/java/database/create.sh" "create.sh"
check_directory "$git_repo_path/java/database/dropdb.sql" "dropdb.sql"
check_directory "$git_repo_path/java/database/schema.sql" "schema.sql" 
check_directory "$git_repo_path/java/database/data.sql" "data.sql"
check_directory "$git_repo_path/java/database/user.sql" "user.sql" 

# Exit if any file/directory is not present
if [ "$all_present" = false ]; then
    echo "\033[0;31m❌ Cannot continue with the installation because the project structure does not match what is expected.\033[0m"
    exit 1
fi

echo "\033[0;32mValidation completed. Your capstone directory structure matches what is expected for installation. You are ready to Dockerize your capstone!🐋\033[0m"


# Define a suffix based on the test variable
iftest=""
if [ "$test" = true ]; then
    iftest="-test"
fi

# Function to display and copy files
# Function to display and copy files
# Function to display and copy files
# Function to display and copy files
copy_files() {
    declare -a file_pairs
    local overwrite_needed=false

    for arg in "$@"; do
        file_pairs+=("$arg")
    done

    if [ "$test" = true ]; then
        echo "The following files will simulate a copy into your capstone git repo:"
    else
        echo "The following files will be copied:"
    fi
    
    for ((i = 0; i < ${#file_pairs[@]}; i+=2)); do
        local source_file=${file_pairs[i]}
        local destination_file=${file_pairs[i+1]}
        echo "🐋 $source_file -> $destination_file"

        if [ -f "$destination_file" ]; then
            overwrite_needed=true
        fi
    done
if [ "$overwrite_needed" = true ]; then
    echo "\033[1m\033[0;33m❓Caution: some Docker files already exist from a previous installation or previous Dockerization effort.\033[0m" 
    read -p "Before we proceed, do you give permission to overwrite the existing Dockerfiles? No Capstone files will be touched. (y/n) " -n 1 -r overwrite_reply
    echo
    if [[ $overwrite_reply =~ ^[Nn]$ ]]; then
        echo "\033[0;31mOverwrite operation cancelled. No Docker files will be copied.\033[0m"
        exit 0
    fi
    # If user agrees to overwrite, proceed with the next confirmation
fi

# Ask to proceed with copying, only if overwrite is confirmed or not needed
read -p "Final confirmation: Do you want to proceed with copying these Docker files? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "\033[0;31mCopy operation cancelled.\033[0m"
    exit 0
fi
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for ((i = 0; i < ${#file_pairs[@]}; i+=2)); do
            local source_file=${file_pairs[i]}
            local destination_file=${file_pairs[i+1]}

            if [ "$test" = true ]; then
                if [ -f "$destination_file" ]; then
                    echo "\033[1m\033[0;33mWould have overwritten $destination_file\033[0m"
                else
                    echo "\033[1m\033[0;33mSimulating copy of $source_file to $destination_file\033[0m"
                fi
            else
                if [ -f "$destination_file" ]; then
                    echo "Overwriting $destination_file"
                fi
                cp "$source_file" "$destination_file"
                echo "Copied $source_file to $destination_file"
            fi
        done
    else
        echo "\033[0;31mCopy operation cancelled.\033[0m"
        exit 0;
    fi
}

# Call the function with all file pairs as arguments
copy_files "./docker-compose$iftest.yml" "$git_repo_path/docker-compose.yml" \
           "./java/JavaDockerfile$iftest" "$git_repo_path/JavaDockerfile" \
           "./java/database/DatabaseDockerfile$iftest" "$git_repo_path/DatabaseDockerfile" \
           "./vue/VueDockerfile$iftest" "$git_repo_path/VueDockerfile"


# After the successful completion of the copy_files function
echo "\033[0;32mAll files have been successfully copied. Please 'cd' into your project repository and type 'docker-compose up' to start your project.\033[0m"

read -p "Would you like this script to 'cd' into your Git repository and start Docker? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! which docker > /dev/null 2>&1; then
        echo "\033[1m\033[0;33mDocker is not installed. Please install Docker, cd into your capstone directory and type docker compose up\033[0m"
        exit 0;
    else
        echo "Docker is installed. Starting Docker..."
        cd "$git_repo_path" && docker-compose up
    fi
fi

