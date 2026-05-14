#!/usr/bin/env bash

set -euo pipefail

# ==============================
# Script Name: install.sh
# Author: Matan
# ==============================


main() {
    require_root
    load_env
    build_docker_image
    remove_previous_container
    start_container
    install_nginx_config
    validate_nginx_config
    reload_nginx
    print_success
}

load_env() {
    USER_PORT="${PORT:-}"
    USER_VERSION="${VERSION:-}"
    USER_API_KEY="${API_KEY:-}"

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    ENV_FILE="${SCRIPT_DIR}/.env"

    if [[ -f "${ENV_FILE}" ]]; then
        echo "Loading environment variables from ${ENV_FILE}..."
        set -a
        source "${ENV_FILE}"
        set +a
    fi

    PORT="${USER_PORT:-${PORT:-5000}}"
    VERSION="${USER_VERSION:-${VERSION:-latest}}"
    API_KEY="${USER_API_KEY:-${API_KEY:-}}"

    if [[ -z "${API_KEY}" ]]; then
        echo "Error: API_KEY is required. Add it to .env or run: sudo API_KEY=<your-api-key> ./install.sh"
        exit 1
    fi
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Error: this script must be run as root. Use: sudo ./install.sh"
        exit 1
    fi
}

build_docker_image() {
    echo "Building Docker image..."
    docker build -t status-dashboard .
}

remove_previous_container() {
    echo "Removing previous status-dashboard container if it exists..."
    docker rm -f status-dashboard 2>/dev/null || true
}

start_container() {
    echo "Starting status-dashboard container..."
    docker run -d \
        --name status-dashboard \
        --restart unless-stopped \
        -e PORT="${PORT}" \
        -e VERSION="${VERSION}" \
        -e API_KEY="${API_KEY}" \
        -p 127.0.0.1:5000:"${PORT}" \
        status-dashboard
}

install_nginx_config() {
    echo "Installing nginx site config..."

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    cp nginx/status-dashboard /etc/nginx/sites-available/status-dashboard

    ln -sf /etc/nginx/sites-available/status-dashboard /etc/nginx/sites-enabled/status-dashboard

    rm -f /etc/nginx/sites-enabled/default
}

validate_nginx_config() {
    echo "Validating nginx configuration..."
    nginx -t
}

reload_nginx() {
    echo "Reloading nginx..."
    systemctl reload-or-restart nginx
}

print_success() {
    VM_IP="$(hostname -I | awk '{print $1}')"

    echo "Installation completed successfully."
    echo "Service is reachable at: http://${VM_IP}/"
}

main "$@"
