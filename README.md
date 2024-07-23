### **devopsfetch.sh**

**Installation and Configuration Steps:**

1. Ensure that the following commands are installed: `netstat`, `docker`, `awk`, `jq`, `finger`, and `journalctl`.

2. Download the script `devopsfetch.sh` from the provided source.

3. Make the script executable by running `chmod +x devopsfetch.sh`.

4. Place the script in a desired location, such as `/usr/local/bin`.


**Usage Examples for each Command-line Flag:**

|**Flag**|**Usage**|
| ----- | ----- |
|`-p` or `--port`<br>\(with optional port number\)|Displays active ports and services. If a port number is provided, displays detailed information about the specified port.|
|`-d` or `--docker`|Lists all Docker images and containers.|
|`-d <container_name>`|Displays detailed information about the specified Docker container.|
|`-n` or `--nginx`|Displays all Nginx domains and their ports.|
|`-n <domain>`|Displays detailed configuration information for the specified Nginx domain.|
|`-u` or `--users`|Lists all users and their last login times.|
|`-u <username>`|Displays detailed information about the specified user.|
|`-t` or `--time`<br>\(with start and end dates\) |Displays activities within the specified time range in the format 'YYYY-MM-DD YYYY-MM-DD'.|
|`-h` or `--help`|Displays help information about the script's usage.|

**Logging Mechanism and How to Retrieve Logs:**

1. The script utilizes the systemd journal for logging purposes.

2. To retrieve the logs, run the following command: `journalctl -u devopsfetch.service`.

This command will display the logs related to the `devopsfetch` service.