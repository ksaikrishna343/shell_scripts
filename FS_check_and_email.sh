#!/bin/bash

# Define the filesystem to be checked
FILESYSTEM="/dev/sda1"

# Define the threshold limit (in percentage)
THRESHOLD=90

# Get the filesystem usage percentage
USAGE=$(df -h --output=pcent "$FILESYSTEM" | sed '1d' | tr -d ' %')

# Check if usage exceeds the threshold
if [ $USAGE -gt $THRESHOLD ]; then
    echo "Filesystem $FILESYSTEM is at $USAGE% usage. Sending email notification."

    # Define the recipient email address or group email
    RECIPIENT="group@example.com"

    # Define the email subject and body
    SUBJECT="Filesystem $FILESYSTEM Usage Alert"
    BODY="Filesystem $FILESYSTEM is at $USAGE% usage on $(hostname). Please investigate and take appropriate action."

    # Send the email notification
    echo "$BODY" | mail -s "$SUBJECT" "$RECIPIENT"

    echo "Email notification sent to $RECIPIENT."
else
    echo "Filesystem $FILESYSTEM usage is within threshold limit."
fi
