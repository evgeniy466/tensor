#!/bin/bash

srcDir="/var/data1"
destDir="/var/data2"

echo "Choose a way to move:"
echo "1. Physical movement"
echo "2. Creating symbolic links"
read -p "Enter 1 or 2: " choice

if [[ "$choice" != "1" && "$choice" != "2" ]]
then
    echo "Wrong choice. Please run the script again and enter 1 or 2."
    exit 1
fi

repack7zToZip() {
    file="$1"
    newDir="$2"
    baseName=$(basename "$file" .7z)
    
    fileWithoutArch=$(echo "$baseName" | sed -r 's/_([a-z0-9а-я]+)_([a-z0-9а-я_]+)$//')
    
    7z x "$file" -o/tmp/"$fileWithoutArch"
    7z a -tzip "$newDir/$fileWithoutArch.zip" /tmp/"$fileWithoutArch"/*
    rm -rf /tmp/"$fileWithoutArch"
}

find "$srcDir" -regex ".*\.\(zip\|7z\)$" | while IFS= read -r fullPath
do
    relativePath="${fullPath#/var/data1/}"
    version=$(echo "$relativePath" | cut -d '/' -f 1)
    nameService=$(echo "$relativePath" | cut -d '/' -f 2)
    buildNumber=$(echo "$relativePath" | cut -d '/' -f 3)
    fileName=$(basename "$relativePath")
    rawFileName=$(basename "$fileName" | sed 's/\.[^.]*$//')
    extension="${fileName##*.}"
    
    if [[ "$rawFileName" =~ _([a-z0-9а-я_]+)$ ]]
    then
        architecture="${BASH_REMATCH[1]}"
    else
        echo "Architecture not found in $rawFileName"
        continue
    fi
    
    fileWithoutArch=$(echo "$rawFileName" | sed "s/_${architecture}\$//")
    
    newDir="$destDir/$nameService/$version/$buildNumber/$architecture"
    mkdir -p "$newDir"
    
    if [[ "$choice" == "1" ]]
    then
        if [[ "$extension" == "7z" ]]
        then
            repack7zToZip "$fullPath" "$newDir"
            rm "$fullPath"
        else
            mv "$fullPath" "$newDir/$fileWithoutArch.zip"
        fi
    else
        if [[ "$extension" == "7z" ]]
        then
            ln -s "$fullPath" "$newDir/$fileWithoutArch.zip"
        else
            ln -s "$fullPath" "$newDir/$fileWithoutArch.zip"
        fi
    fi
done

echo "Done."