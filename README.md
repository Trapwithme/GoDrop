# GoDrop

## Overview
This Go program downloads a batch file from a specified URL, saves it to a temporary directory with a random filename, and executes it on a Windows system. The batch file is executed silently using a VBS script. The program includes functions to perform unnecessary calculations, likely for obfuscation purposes.

## Features
- **Random Filename Generation**: Generates a random string for naming the downloaded file to avoid detection.
- **HTTP File Download**: Retrieves a batch file from a provided URL.
- **Silent Execution via VBS**: Executes the batch file on Windows using a VBS script for hidden execution.
- **Platform Check**: Ensures execution only on Windows systems for batch files.
- **Obfuscation**: Includes dummy functions to perform unnecessary calculations, potentially to complicate static analysis.

## Prerequisites
- **Go**: Install [Go](https://golang.org/dl/) to compile and run the program.
- **Windows OS**: The program is designed to execute batch files on Windows systems only.
- **Internet Access**: Required to download the batch file from the specified URL.

## Build Command
1. go build -o downloader.exe -ldflags "-H=windowsgui" godrop.go
