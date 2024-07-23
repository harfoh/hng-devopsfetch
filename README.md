# **Devopsfetch.sh**


## **Overview**

DevOpsFetch is a powerful command-line tool designed to provide a centralized view of your system's health and activity. It gathers information from various sources, including network ports, Docker containers, Nginx configurations, system users, and system logs.

## **Installation and Configuration Steps:**

###  Init/Installation Script 
This script ensures that the following commands are installed: `netstat`, `docker`, `awk`, `jq`, `finger`, and `journalctl`.
Also, it ensures that all the necessary dependencies are installed, sets up the devopsfetch script, creates a systemd service for continuous execution, and configures log rotation. 
Lastly, it makes the script executable and places the script in the desired location. 


## **Usage**

DevOpsFetch provides various commands to retrieve system information. You can access these commands by running the `devopsfetch` script with the appropriate flags.

**Command-Line Flags:**

| Flag | Long Flag | Description | Usage Example |
|---|---|---|---|
| `-p` | `--port` | Display active ports and services. | `sudo devopsfetch -p` |
| `-p <port_number>` | `--port <port_number>` | Display detailed information about a specific port. | `sudo devopsfetch -p 80` |
| `-d` | `--docker` | List all Docker images and containers. | `devopsfetch -d` |
| `-d <container_name>` | `--docker <container_name>` | Display detailed information about a specific container. | `sudo devopsfetch -d my-app` |
| `-n` | `--nginx` | Display all Nginx domains and their ports. | `devopsfetch -n` |
| `-n <domain>` | `--nginx <domain>` | Display detailed configuration information for a specific domain. | `sudo devopsfetch -n example.com` |
| `-u` | `--users` | List all users and their last login times. | `devopsfetch -u` |
| `-u <username>` | `--users <username>` | Display detailed information about a specific user. | `sudo devopsfetch -u ThePrimeJnr` |
| `-t` | `--time` | Display activities within a specified time range. | `sudo devopsfetch -t 2024-07-18 2024-07-23` |
| `-h` | `--help` | Display help message. | `sudo devopsfetch -h` |

**Example Usage:**

- **List active ports:**
```bash
sudo devopsfetch -p
```

- **Get details about port 80:**
```bash
sudo devopsfetch -p 80
```

- **List Docker containers:**
```bash
sudo devopsfetch -d
```

- **Get details about the container named 'my-app':**
```bash
sudo devopsfetch -d my-app
```

- **List Nginx domains:**
```bash
sudo devopsfetch -n
```

- **Get configuration details for the domain 'example.com':**
```bash
sudo devopsfetch -n example.com
```

- **List system users:**
```bash
sudo devopsfetch -u
```

- **Get details about the user 'ThePrimeJnr':**
```bash
devopsfetch -u ThePrimeJnr
```

- **Display activities from July 18th to 23rd:**
```bash
sudo devopsfetch -t 2024-07-18 2024-07-23
```

## **Logging**

DevOpsFetch logs its activities to the file `/var/log/devopsfetch.log`. This log file contains timestamps and details of each command executed.

**Retrieving Logs:**

- You can view the log file directly using a text editor:
```bash
cat /var/log/devopsfetch.log
```

- You can also use the `tail` command to view the latest entries:
```bash
tail /var/log/devopsfetch.log
```

- The `logrotate` utility is configured to rotate the log file daily, keeping a maximum of 7 compressed log files.

## **Conclusion**

DevOpsFetch provides a comprehensive and efficient way to monitor your system's health and activity. Its user-friendly interface and detailed information make it an invaluable tool for DevOps professionals and system administrators.
