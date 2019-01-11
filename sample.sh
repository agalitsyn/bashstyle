#!/usr/bin/env bash
# vim: ts=4 sts=4 sw=4 noet:

set -eo pipefail; [[ $TRACE ]] && set -x

SCRIPT_DIR="$(dirname "$0")"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

announce_step() {
    echo
    echo "===> $*"
    echo
}

usage() {
    cat >&2 <<EOT
Sample bash script template

Usage: $0 { foo | bar } [ --option VAL ]

Commands:
    foo                   - do somehting
    bar                   - do something too

Options:
    --option VAL          - additional flag to do smth

Requirements:
	- utility (like git)

Environment:
	GLOBAL_VARIABLE       - Some variable for global overiides
EOT
    exit 2
}

end() {
    announce_step "DONE."
}

handle_foo_action() {
	echo 'foo action'
}

handle_bar_action() {
	echo 'bar action'
}

# Package manager installer example
install_common_utils() {
	local utils=( git )

	for util in "${utils[@]}"; do
		if ! rpm --query "$util" > /dev/null 2>&1; then
			announce_step "Installing $util"
			sudo yum install --assumeyes "$util"
		fi
	done
}

check_system_dependencies() {
    announce_step 'Check that system dependencies installed'

    local default_packages=( python )
    local packages=(${1:-${default_packages[@]}})

    for package in "${packages[@]}"
    do
        if [[ $(is_deb_installed $package) -eq 0 ]]; then die "Package $package is required!"; fi
    done
}

is_deb_installed() {
    local usage='is_package_installed {package_name}'
    local package_name=${1:?$usage}

    dpkg-query -W -f='${Status}' $package_name 2>/dev/null | grep -c "ok installed"
}

# Installer example
install_python_pip() {
	if pip --version > /dev/null 2>&1; then
		return
	fi

	announce_step 'Installing python-pip'
	curl --silent --show-error --location "https://bootstrap.pypa.io/get-pip.py" | sudo python
}

# Installer example
install_golang() {
	if [ -f /opt/go/bin/go ]; then
		return
	fi

	local version=${1:-"1.6.2"}

	announce_step "Installing Go $version"
	cd /tmp && curl --silent --show-error --location "https://storage.googleapis.com/golang/go${version}.linux-amd64.tar.gz" | tar --extract --gzip
	sudo mv /tmp/go $GOROOT

}

# bashrc appending example
configure_golang_env() {
	export GOROOT=/opt/go
    export GOPATH=/vagrant
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

	if grep --quiet GOPATH ~/.bashrc; then
		return
	fi

	announce_step 'Configure Go environment variables'
	echo "export GOROOT=$GOROOT" >> ~/.bashrc
	echo "export GOPATH=$GOPATH" >> ~/.bashrc
	echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ~/.bashrc
}

# Helper example
create_dir_and_chown() {
	local dir=${1:?"dir path is required"}

	if [ -d $dir ]; then
		return
	fi

	announce_step "Create $dir"
	sudo mkdir --parents "$dir"
	sudo chown --recursive $USER:$USER "$dir"
}

# Cycle example
create_project_folders() {
	local folders=( /tmp/folder-one /tmp-folder-two )

	for folder in "${folders[@]}"; do
		create_dir_and_chown "$folder"
	done
}

# Example of unpack string to array and check
check_clients() {
    local usage="check_clients {\"client_one_name client_two_name\"}"
    local clients=(${1:?$usage})

    for client in "${clients[@]}"; do
        $($client --version) > /dev/null 2>&1 || die "client \"$client\" was not found."
    done
}

# Example templating
create_file() {
    local usage="create_file {file_name} {some_placeholder}"
    local file_name=${1:?$usage}
    local some_placeholder=${2:?$usage}

    cat > "/tmp/$file_name" <<EOF
    Here it is: $some_placeholder
EOF
    echo "File /tmp/$file_name was created."
}

# Polling example
wait_for_status() {
    local usage='wait_for_status {stack_name} {status}'
    local name=${1:?$usage}
    local expected_status=${2:?$usage}
    local actual_status=

    while true
        do
            actual_status=$(get_status $name)
            if [[ $expected_status = $actual_status ]]; then
                echo "Status \"$actual_status\" is expected. Success."
                break
            elif [[ $actual_status =~ '_IN_PROGRESS' ]]; then
                echo "Status is \"$actual_status\". Next polling in 3 sec."
                sleep 3
            elif [[ $actual_status =~ '_FAILED' ]]; then
                echo "Status is \"$actual_status\"." && return
            else
                echo 'Cant find any status for stack. Abort.'
                break
            fi
        done
}

# Example exit code
ensure_exit_code() {
	/usr/bin/env python2 -mSimpleHTTPServer 5000 &
	PID=$!

	kill -SIGTERM $PID
	wait

	echo $?
}


# Globals

export GLOBAL_VARIABLE=${GLOBAL_VARIABLE:-"default value"}

# Constants

ROOT_D="/usr/local"

arg_action="${1:?$(usage)}"
arg_action="$(echo $arg_action | sed -e 's/-/_/g')"
shift || :

# Parse opts

opt_one=
opt_bool=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --one)
            opt_one="$2"
            [ "$#" -ge 2 ] && shift 2 || break
            ;;
        --bool)
            opt_bool="true"
            shift
            ;;
        --help)
            usage
            shift
            ;;
        *)
            die "Unknown option: $1"
    esac
done

# Sanity checks

d

# Main logic

check_prerequisites
"handle_${arg_action}_action"
end

announce_step "Begin..."

[ -z "$opt_bool" ] || die "Sample error message"

end
