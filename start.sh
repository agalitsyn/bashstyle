#!/usr/bin/env bash

set -eo pipefail; [[ $TRACE ]] && set -x

ensure_nginx_is_up() {
	local nginx_endpoint="http://${NGINX_SERVICE_HOST}:${NGINX_SERVICE_PORT}"

	announce_step "Ensure nginx is up"

    wait_for_http_code "$nginx_endpoint" "200" "5" "30"
}

main() {
	# Env
    readonly NGINX_SERVICE_HOST=${NGINX_SERVICE_HOST:?"required variable"}
    readonly NGINX_SERVICE_PORT=${NGINX_SERVICE_PORT:?"required variable"}

	# Constants
	readonly SCRIPT_DIR="$(dirname "$0")"

	source "${SCRIPT_DIR}/helpers.sh"

    check_prerequisites "curl --help" "kubectl"
    ensure_nginx_is_up
	end
}

main
