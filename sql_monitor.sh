#!/bin/bash

# Load the environment variables

source "$(dirname "$0")/.env"

# 1. Check Service, Port, and Docker Container
ISSUES=""

# Check systemctl service (only if SERVICE_NAME is defined)
if [ ! -z "$SERVICE_NAME" ]; then
    SERVICE_STATUS=$(systemctl is-active "$SERVICE_NAME")
    if [ "$SERVICE_STATUS" != "active" ]; then
        ISSUES+="* Service $SERVICE_NAME is $SERVICE_STATUS\n"
    fi
fi

# Check Docker container (only if CONTAINER_NAME is defined)
if [ ! -z "$CONTAINER_NAME" ]; then
    DOCKER_STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
    if [ "$DOCKER_STATUS" != "running" ]; then
        ISSUES+="* Docker container $CONTAINER_NAME is ${DOCKER_STATUS:-not found}\n"
    fi
fi

PORT_CHECK=$(ss -tulpn | grep -w 1433)
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