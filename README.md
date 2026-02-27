# SQL Monitoring & Email Notification

A simple shell script to monitor the status of a Microsoft SQL Server instance and send email alerts if the service is down or the port is not listening.

## Features

- Checks if `mssql-server` service is active using `systemctl`.
- Checks if port `1433` is listening using `ss`.
- Sends email notifications via SMTP using `swaks`.
- Configurable through environment variables.

## Prerequisites

- Linux system with `systemctl` and `ss` commands available.
- `swaks` (Swiss Knife for SMTP) installed.
- A running MS SQL Server (`mssql-server`) instance.
- Access to an SMTP server for sending emails.

## Installation

To download the script directly from the repository:

```bash
curl -O https://raw.githubusercontent.com/rockymount114/email-notification/main/sql_monitor.sh
```

## Configuration

Create a `.env` file in the same directory as the script with the following variables:

```bash
RECIPIENT="admin@example.com"
EMAIL_ADDRESS="alerts@example.com"
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
EMAIL_PASSWORD="your_secure_password"
SERVICE_NAME="mssql-server" # Optional: systemctl service name to monitor
CONTAINER_NAME="sql_container" # Optional: Docker container name to monitor
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `RECIPIENT` | The email address(es) that will receive the alerts. For multiple recipients, use a comma-separated list (e.g., `user1@example.com,user2@example.com`). |
| `EMAIL_ADDRESS` | The 'from' email address and SMTP authentication username. |
| `SMTP_SERVER` | The hostname of your SMTP server. |
| `SMTP_PORT` | The port for your SMTP server (e.g., 587 for TLS). |
| `EMAIL_PASSWORD`| The password for SMTP authentication. |
| `SERVICE_NAME` | (Optional) The name of the `systemctl` service to monitor. |
| `CONTAINER_NAME`| (Optional) The name of the Docker container to monitor. |

## Usage

### 1. Make the script executable

```bash
chmod 600 .env
chmod +x sql_monitor.sh
```

### 2. Run manually

```bash
./sql_monitor.sh
```

### 3. Schedule with Cron

To automate monitoring (e.g., every 5 minutes), add a crontab entry:

```bash
*/5 * * * * $(pwd)/sql_monitor.sh > /dev/null 2>&1

or

*/5 * * * * /root/sql_monitor.sh > /dev/null 2>&1
```

## How it Works

1. The script loads configuration from the `.env` file.
2. It executes `systemctl is-active mssql-server` to verify the service status.
3. It uses `ss -tulpn` to check if the SQL port (1433) is open.
4. If either check fails, it compiles a list of issues.
5. If issues are detected, it uses `swaks` to send a TLS-encrypted email with the details.
