#!/usr/bin/python3

import os
import shutil
import sys
from collections import defaultdict

sys.path.append(os.path.join(os.path.dirname(__file__), 'tqdm'))

from tqdm import tqdm

def getAllItems(directoryPath):
    allFiles = []
    allDirs = []
    for root, dirs, files in os.walk(directoryPath, topdown=False):
        for file in files:
            filePath = os.path.join(root, file)
            allFiles.append(filePath)
        for dir in dirs:
            dirPath = os.path.join(root, dir)
            allDirs.append(dirPath)
    return allFiles, allDirs

def clearDirectory(directoryPath):
    fileCount = defaultdict(int)

    allFiles, allDirs = getAllItems(directoryPath)

    totalItems = len(allFiles) + len(allDirs)

    with tqdm(total=totalItems, desc="Deleting files") as pbar:
        for filePath in allFiles:
            if os.path.isfile(filePath):
                fileType = os.path.splitext(filePath)[1] or "withoutExtension"
                try:
                    os.remove(filePath)
                    fileCount[fileType] += 1
                except Exception as e:
                    print(f"Failed to delete file {filePath}: {e}")
            pbar.update(1)

        for dirPath in allDirs:
            if os.path.isdir(dirPath):
                try:
                    shutil.rmtree(dirPath)
                    fileCount["directory"] += 1
                except Exception as e:
                    print(f"Failed to delete directory {dirPath}: {e}")
            pbar.update(1)

    print("\nDeleted files:")
    for fileType, count in fileCount.items():
        print(f"{fileType}: {count}")

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Error: the path to the directory is not specified.")
        sys.exit(1)

    directoryPath = sys.argv[1]

    if not os.path.isdir(directoryPath):
        print(f"Error: the directory on the path '{directoryPath}' does not exist.")
        sys.exit(1)

    clearDirectory(directoryPath)
