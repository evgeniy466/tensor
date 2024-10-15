#!/bin/bash

if [ $# -ne 2 ]
then
  echo "Error: 2 parameters are expected to run."
  exit 1
else
  echo "Script is running with next parameters: 
Path to directory: $1 
Service version: $2"
fi

directory=$1
targetVersion=$2

if [ ! -d "$directory" ] 
then
  echo "Error: Wrong directory format. Expected format: /path/to/directory"
  exit 1
elif ! [[ "$targetVersion" =~ ^[a-zA-Z_]+_[0-9]+(\.[0-9]+)*$ ]]
then
  echo "Error: Wrong version format. Expected format: NameOfService_1.2.3.*"
  exit 1
fi

productTitle=$(echo "$targetVersion" | sed 's/\(.*\)_\(.*\)/\1/')
productVersion=$(echo "$targetVersion" | sed 's/.*_\(.*\)/\1/')

compareVersions() {

    IFS='.' read -r -a version1 <<< "$1"
    IFS='.' read -r -a version2 <<< "$2"
    maxLength=${#version1[@]}
    if [ ${#version2[@]} -gt $maxLength ]
    then
        maxLength=${#version2[@]}
    fi

    for ((i=0; i<maxLength; i++))
    do
        v1=${version1[i]:-0}
        v2=${version2[i]:-0}
        
        if (( v1 < v2 ))
        then
            return 1
        elif (( v1 > v2 ))
        then
            return 0
        fi
    done

    return 2
}

for folder in "$directory"/*
do
    if [ -d "$folder" ]
    then
        folderName=$(basename "$folder")
        if [[ "$folderName" =~ ^$productTitle(_[0-9]+(\.[0-9]+)*)$ ]]
        then
            folderVersion=$(echo "$folderName" | sed 's/.*_\(.*\)/\1/')

            compareVersions "$folderVersion" "$productVersion"

            result=$?
            if [ "$result" -eq 1 ]
            then
                echo "Deleting older version: $folderName"
                rm -rf "$folder"
            elif [ "$result" -eq 0 ]
            then
                echo "Skipping newer version: $folderName"
            else
                echo "Skipping current version: $folderName"
            fi
        fi
    fi
done
