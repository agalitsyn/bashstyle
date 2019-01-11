#!/usr/bin/env bash

set -eo pipefail; [[ $TRACE ]] && set -x

die() {
    echo "ERROR: $*" >&2
    exit 1
}

announce_step() {
	echo
	echo "===> $*"
	echo
}

end() {
    announce_step "DONE."
}

dump_environment_variables() {
	announce_step "Dump environment variables"

	env
}

check_prerequisites() {
	local usage="$FUNCNAME (\"command\" \"command\")"
    local commands=("${@:?$usage}")

	announce_step "Check prerequisites"

    for ((i = 0; i < ${#commands[@]}; i++)); do
        eval "${commands[$i]}" > /dev/null 2>&1 || die "Command \"$cmd\" was failed."
    done
}

wait_for_command() {
	local usage="$FUNCNAME <command> [poll_interval] [retries]"
	local cmd=${1:?$usage}
	local poll_interval=${2:-"1"}
	local attempts=${3:-"10"}

	attempt=1
	until eval "$cmd" >/dev/null 2>&1; do
		echo "Failed. Attempt $attempt of $attempts."

		if [[ "$attempt" -eq "$attempts" ]]; then
			die "all attempts were failed"
		fi

		sleep "$poll_interval"
		((attempt++))
	done
}

wait_for_http_code() {
	local usage="$FUNCNAME <endpoint> <http_code> [poll_interval] [retries]"
	local endpoint=${1:?$usage}
	local http_code=${2:?$usage}
	local poll_interval=${3:-"1"}
	local attempts=${4:-"10"}

	wait_for_command \
		"[[ $(curl --output /dev/null --silent --head --fail --max-time 1 --write-out '%{http_code}' "$endpoint") == $http_code ]]" \
		"$poll_interval" "$attempts"
}

