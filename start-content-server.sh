#!/bin/bash
# Script to start a dedicated content server

echo "Installing required dependencies if not present..."
npm install --no-save express cors

echo "Running content file generator..."
./generate-all-content-files.sh

echo "Starting content server on port 4202..."
node ./content-server.js
