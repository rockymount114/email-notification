#!/bin/bash

# Load the environment variables

source "$(dirname "$0")/.env"

# 1. Check Service and Port
ISSUES=""
SERVICE_STATUS=$(systemctl is-active mssql-server)
PORT_CHECK=$(ss -tulpn | grep -w 1433)

if [ "$SERVICE_STATUS" != "active" ]; then
    ISSUES+="* SQL Service is $SERVICE_STATUS\n"
fi

if [ -z "$PORT_CHECK" ]; then
    ISSUES+="* Port 1433 is NOT listening\n"
fi

# 2. If issues found, send email via Swaks
if [ ! -z "$ISSUES" ]; then
    echo "Issues detected. Sending email..."

    swaks --to "$RECIPIENT" \
          --from "$EMAIL_ADDRESS" \
          --server "$SMTP_SERVER" \
          --port "$SMTP_PORT" \
          --auth LOGIN \
          --auth-user "$EMAIL_ADDRESS" \
          --auth-password "$EMAIL_PASSWORD" \
          -tls \
          --header "Subject: SQL Alert: $(hostname)" \
          --body "The following issues were detected on your SQL Server:\n\n$ISSUES"
else
    echo "SQL Server is healthy."
fi