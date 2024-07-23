#!/bin/bash

# Define Constants
ACTIVE_PORTS_FLAG="-p"
ACTIVE_PORTS_LONG_FLAG="--port"

DOCKER_FLAG="-d"
DOCKER_LONG_FLAG="--docker"

NGINX_FLAG="-n"
NGINX_LONG_FLAG="--nginx"

USERS_FLAG="-u"
USERS_LONG_FLAG="--users"

TIME_RANGE_FLAG="-t"
TIME_RANGE_LONG_FLAG="--time"

HELP_FLAG="-h"
HELP_LONG_FLAG="--help"

LOG_FILE="/var/log/devopsfetch.log"

# Check for required commands
for cmd in netstat docker awk jq finger journalctl; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Define Functions

# Display active ports and services
function display_active_ports() {
    echo -e "\nActive Ports and Services:"
    netstat -tulpn | awk '{printf "%-6s %-20s %-20s %s\n", $1, $4, $6, $7}' | column -t
}

# Display detailed information about a specific port
function display_port_details() {
    local port_number="$1"
    echo -e "\nDetailed Information about Port $port_number:"
    netstat -tulpn | awk -v port="$port_number" '$4 ~ ":"port {printf "%-6s %-20s %-20s %s\n", $1, $4, $6, $7}' | column -t
}

# List all Docker images and containers
function list_docker_images() {
    echo -e "\nDocker Images:"
    docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}" | column -t

    echo -e "\nDocker Containers:"
    docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | column -t
}

# Provide detailed information about a specific container
function display_container_details() {
    local container_name="$1"
    echo -e "\nDetailed Information about Container $container_name:"
    docker container inspect "$container_name" | jq '.[] | {
        Id: .Id,
        Name: .Name,
        Image: .Image,
        State_Status: .State.Status,
        State_Running: .State.Running,
        NetworkSettings_IPAddress: .NetworkSettings.IPAddress,
        Ports: .NetworkSettings.Ports,
        Config_Env: .Config.Env
    }' | jq .
}

# Display all Nginx domains and their ports
function display_nginx_domains() {
    echo -e "\nNginx Domains and Ports:"
    awk '/server_name/ {gsub(";", ""); server_name=$2} /listen/ {gsub(";", ""); print server_name, $2}' /etc/nginx/sites-enabled/* | column -t
}

# Provide detailed configuration information for a specific domain
function display_domain_details() {
    local domain_name="$1"
    echo -e "\nDetailed Configuration for Domain $domain_name:"
    awk -v domain="$domain_name" '/server_name/ {if ($2 == domain) {found=1} else if (/}/) {found=0} if (found) print}' /etc/nginx/sites-enabled/* | column -t
}

# List all users and their last login times
function list_users() {
    echo -e "\nUsers and Last Login Times:"
    lastlog | awk '{printf "%-20s %-30s %-20s\n", $1, $4, $5" "$6" "$7" "$8}' | column -t
}

# Provide detailed information about a specific user
function display_user_details() {
    local username="$1"
    echo -e "\nDetailed Information about User $username:"
    finger "$username"
}

# Display activities within a specified time range
function display_activities_in_time_range() {
    local start_date="$1"
    local end_date="$2"

    # Convert dates to timestamps
    local start_timestamp=$(date -d "$start_date" +%s 2>/dev/null)
    local end_timestamp=$(date -d "$end_date" +%s 2>/dev/null)

    if [[ -z "$start_timestamp" || -z "$end_timestamp" ]]; then
        echo -e "Error: Invalid date format. Use format YYYY-MM-DD YYYY-MM-DD."
        return 1
    fi

    echo -e "\nActivities from $start_date to $end_date:"
    journalctl --since="$start_date" --until="$end_date" -u devopsfetch.service | column -t
}

# Print help message
function display_help() {
    echo -e "\nDevOpsFetch Help:"
    echo -e "\nUsage: devopsfetch [FLAGS]"
    echo -e "\nFlags:"
    echo -e "$ACTIVE_PORTS_FLAG or $ACTIVE_PORTS_LONG_FLAG\tDisplay active ports and services"
    echo -e "$ACTIVE_PORTS_FLAG <port_number>\t\tDisplay detailed information about a specific port"
    echo -e "$DOCKER_FLAG or $DOCKER_LONG_FLAG\tList all Docker images and containers"
    echo -e "$DOCKER_FLAG <container_name>\t\tDisplay detailed information about a specific container"
    echo -e "$NGINX_FLAG or $NGINX_LONG_FLAG\tDisplay all Nginx domains and their ports"
    echo -e "$NGINX_FLAG <domain>\t\tDisplay detailed configuration information for a specific domain"
    echo -e "$USERS_FLAG or $USERS_LONG_FLAG\tList all users and their last login times"
    echo -e "$USERS_FLAG <username>\t\tDisplay detailed information about a specific user"
    echo -e "$TIME_RANGE_FLAG or $TIME_RANGE_LONG_FLAG\tDisplay activities within a specified time range in the format 'YYYY-MM-DD YYYY-MM-DD'"
    echo -e "$HELP_FLAG or $HELP_LONG_FLAG\tDisplay this help message"
    echo -e "\nNote: For detailed information about a specific port, container, domain, or user, provide the corresponding name or number after the flag."
}

# Main Function

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
    $ACTIVE_PORTS_FLAG | $ACTIVE_PORTS_LONG_FLAG)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            display_port_details "$2"
            shift 2
        else
            display_active_ports
            shift
        fi
        ;;
    $DOCKER_FLAG | $DOCKER_LONG_FLAG)
        if [[ -n "$2" ]]; then
            display_container_details "$2"
            shift 2
        else
            list_docker_images
            shift
        fi
        ;;
    $NGINX_FLAG | $NGINX_LONG_FLAG)
        if [[ -n "$2" ]]; then
            display_domain_details "$2"
            shift 2
        else
            display_nginx_domains
            shift
        fi
        ;;
    $USERS_FLAG | $USERS_LONG_FLAG)
        if [[ -n "$2" ]]; then
            display_user_details "$2"
            shift 2
        else
            list_users
            shift
        fi
        ;;
    $TIME_RANGE_FLAG | $TIME_RANGE_LONG_FLAG)
        if [[ -n "$2" && -n "$3" ]]; then
            display_activities_in_time_range "$2" "$3"
            shift 3
        else
            echo -e "Error: Please specify a start and end date after the -$TIME_RANGE_FLAG or --$TIME_RANGE_LONG_FLAG flag."
            exit 1
        fi
        ;;
    $HELP_FLAG | $HELP_LONG_FLAG)
        display_help
        exit 0
        ;;
    *)
        echo -e "Error: Invalid flag $1. Use -$HELP_FLAG or --$HELP_LONG_FLAG for help."
        exit 1
        ;;
    esac
done

# Log activities
echo -e "\n$(date) - Command: $0 $@" >> "$LOG_FILE"
