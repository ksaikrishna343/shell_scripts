#!/bin/bash

# Define the service name to be checked
SERVICE_NAME="your_service_name"

# Check if the service is running
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "Service $SERVICE_NAME is running."
else
    echo "Service $SERVICE_NAME is not running. Sending email notification."

    # Define the recipient email address or group email
    RECIPIENT="group@example.com"

    # Define the email subject and body
    SUBJECT="Service $SERVICE_NAME is not running"
    BODY="Service $SERVICE_NAME is not running on $(hostname). Please investigate and take appropriate action."

    # Send the email notification
    echo "$BODY" | mail -s "$SUBJECT" "$RECIPIENT"

    echo "Email notification sent to $RECIPIENT."
fi
