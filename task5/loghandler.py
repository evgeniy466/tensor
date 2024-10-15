#!/usr/bin/python3

import csv
from datetime import datetime
from statistics import mean, median
from pathlib import Path

def calculateTimeDiff(startTime, endTime):
    format = '%d.%m.%Y %H:%M:%S'
    startDatetime = datetime.strptime(startTime, format)
    endDatetime = datetime.strptime(endTime, format)
    return (endDatetime - startDatetime).total_seconds()

def analyzeLog(filePath):
    requestTimes = []
    errorCount = 0
    totalRequests = 0
    pageRequests = {}

    filePath = Path(filePath)

    if not filePath.is_file():
        print(f"The file in the path '{filePath}' was not found.")
        return

    with open(filePath, 'r') as file:
        reader = csv.reader(file, delimiter='|')
        for row in reader:
            startTime, endTime, reqPath, respCode, respBody = map(str.strip, row)
            totalRequests += 1

            requestTime = calculateTimeDiff(startTime, endTime)
            requestTimes.append(requestTime)

            if reqPath not in pageRequests:
                pageRequests[reqPath] = 0
            pageRequests[reqPath] += 1

            if int(respCode) >= 400 or "error" in respBody.lower():
                errorCount += 1

    minTime = min(requestTimes) if requestTimes else 0
    maxTime = max(requestTimes) if requestTimes else 0
    avgTime = mean(requestTimes) if requestTimes else 0
    medianTime = median(requestTimes) if requestTimes else 0
    errorPercentage = (errorCount / totalRequests) * 100 if totalRequests else 0

    print("Statistical characteristics of processing time:")
    print(f"Minimal time: {minTime:.2f} sec")
    print(f"Maximal time: {maxTime:.2f} sec")
    print(f"Average time: {avgTime:.2f} sec")
    print(f"Median time: {medianTime:.2f} sec")

    print(f"\nPercentage of erroneous requests: {errorPercentage:.2f}%")

    print("\nDistribution of calls by pages:")
    for page, count in pageRequests.items():
        print(f"{page}: {count} time(s)")

logFilePath = input("Enter the path to the log file: ")
analyzeLog(logFilePath)