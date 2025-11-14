#!/bin/bash
# This script runs /start.sh in the background to start Jupyter/SSH services,
# then executes your application.
#
# Usage: Modify this file to add your own commands after services start.

# Start base image services (Jupyter/SSH) in background
/start.sh &

# Wait a moment for services to start
sleep 2

# Add your application commands here
python /app/main.py

# Wait for background processes
wait

