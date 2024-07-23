#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Installation of necessary dependencies
install_dependencies() {
    echo "Updating package list..."
    sudo apt-get update || { echo "Failed to update package list"; exit 1; }

    echo "Checking for necessary dependencies..."

    if ! is_installed net-tools; then
        echo "Installing net-tools..."
        sudo apt-get install -y net-tools || { echo "Failed to install net-tools"; exit 1; }
    else
        echo "net-tools is already installed."
    fi

    if ! is_installed docker.io; then
        echo "Installing Docker..."
        sudo apt-get remove -y containerd.io containerd || { echo "Failed to remove conflicting containerd packages"; exit 1; }
        sudo apt-get install -y docker.io || { echo "Failed to install Docker"; exit 1; }
    else
        echo "Docker is already installed."
    fi

    if ! is_installed nginx; then
        echo "Installing Nginx..."
        sudo apt-get install -y nginx || { echo "Failed to install Nginx"; exit 1; }
    else
        echo "Nginx is already installed."
    fi

    if ! is_installed jq; then
        echo "Installing jq..."
        sudo apt-get install -y jq || { echo "Failed to install jq"; exit 1; }
    else
        echo "jq is already installed."
    fi

    if ! is_installed finger; then
        echo "Installing finger..."
        sudo apt-get install -y finger || { echo "Failed to install finger"; exit 1; }
    else
        echo "finger is already installed."
    fi
}

# Create systemd service for continuous monitoring
create_systemd_service() {
    sudo bash -c 'cat <<EOL > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch
Restart=always
RestartSec=60  # Restart every 1 minute
StartLimitIntervalSec=300  # 5 minutes interval for rate limiting
StartLimitBurst=3  # Maximum of 3 restarts within interval
User=root
StandardOutput=journal
StandardError=journal
SyslogIdentifier=devopsfetch

[Install]
WantedBy=multi-user.target
EOL'

    sudo systemctl daemon-reload || { echo "Failed to reload systemd daemon"; exit 1; }
    sudo systemctl enable devopsfetch || { echo "Failed to enable devopsfetch service"; exit 1; }
    sudo systemctl start devopsfetch || { echo "Failed to start devopsfetch service"; exit 1; }
}

# Setup logging and log rotation
setup_logging() {
    sudo bash -c 'cat <<EOL > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
    postrotate
        systemctl reload devopsfetch
    endscript
}
EOL'
}

# Create log file with proper permissions
create_log_file() {
    sudo touch /var/log/devopsfetch.log
    sudo chmod 664 /var/log/devopsfetch.log
    sudo chown root:adm /var/log/devopsfetch.log
}

# Main function for continuous execution
main() {
    install_dependencies
    sudo cp devopsfetch.sh /usr/local/bin/devopsfetch || { echo "Failed to copy devopsfetch script"; exit 1; }
    sudo chmod +x /usr/local/bin/devopsfetch || { echo "Failed to make devopsfetch script executable"; exit 1; }
    create_systemd_service
    setup_logging
    echo "DevOpsFetch tool installed and systemd service started."
}

# Start the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    while true; do
        main
        sleep 300  # Sleep for 5 minutes before running again
    done
fi
