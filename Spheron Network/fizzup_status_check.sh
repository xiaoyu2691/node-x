#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

# Log functions
function log_info() {
    echo -e "${WHITE}[INFO] $(date '+%Y-%m-%d %H:%M:%S') $@${NOCOLOR}"
}

function log_err() {
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $@${NOCOLOR}"
}

function log_warn() {
    echo -e "${YELLOW}[WARN] $(date '+%Y-%m-%d %H:%M:%S') $@${NOCOLOR}"
}

function log_debug() {
    echo -e "${GREEN}[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') $@${NOCOLOR}"
}

function check_fizz_status() {
    container_name=$(docker ps -a --format "{{.Names}}" | grep "fizz")
    status=$(docker inspect -f '{{.State.Status}}' "$container_name")

        case "$status" in
            exited|created)
                log_warn "Container $container_name $status "
		exit 1
                ;;
            running)
	        log_info "Container $container_name is running."
		docker compose -f ~/.spheron/fizz/docker-compose.yml logs --tail=100	
		exit 0
                ;;
        esac
}

check_fizz_status
