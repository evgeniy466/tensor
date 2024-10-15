#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Error: directory path parameter is expected to run."
  exit 1
elif [ ! -d "$1" ]
then
    echo "Error: Wrong directory format. Expected format: /path/to/directory"
else
  echo "Script is running with the following parameter:" 
  echo "Path to directory: $1"
fi

filesOps() {
    mainFiles=()
    additionalFiles=()
  
    for file in "$subdir"/*
    do
        if [[ -f $file ]]
        then
            if [[ $file =~ \.[a-zA-Z0-9]{1,5}$ ]]
            then
                additionalFiles+=("$file")
            else
                mainFiles+=("$file")
            fi
        fi
    done

    if [[ ${#mainFiles[@]} -eq 0 ]]
    then
        if [[ ${#additionalFiles[@]} -eq 1 ]]
        then
            echo "There is 1 additional file ${additionalFiles[0]}. Renaming it to the main."
            mv "${additionalFiles[0]}" "${additionalFiles[0]%%.*}"
        elif [[ ${#additionalFiles[@]} -ge 2 ]]
        then
            echo "Error: several additional files without a main file in $subdir"
        fi
    else
        mainFile="${mainFiles[0]}"
        mainSize=$(stat -c%s "$mainFile")
        
        for additionalFile in "${additionalFiles[@]}"
        do
            additionalSize=$(stat -c%s "$additionalFile")
            if [[ $additionalSize -gt $mainSize ]]
            then
                echo "The size of the additional file $additionalFile is larger than the main one $mainFile, replacing the main file."
                rm "$mainFile"
                mv "$additionalFile" "$mainFile"
            else
                echo "Deleting the additional file $additionalFile."
                rm "$additionalFile"
            fi
        done
    fi
}

scanDir() {
    for subdir in "$1"/*
    do
        if [ -d "$subdir" ]
        then
            echo "Scanning directory: $subdir"
            filesOps "$subdir"
        fi
    done
}

scanDir "$1"