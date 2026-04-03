#! /bin/bash

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

function show_help() {
    echo "Start docker container for AOSP build env"
    echo ""
    echo "Args:"
    echo "    -ov|--os_version:  OS version. i.e. 18.04, 20.04. Default is 18.04, which mean ubuntu 18.04"
    echo ""
}

function parse_os_version() {
    # $1: os verson
    # $2: available versions
    _ov="$1"
    shift

    _found=0
    for _version in "$@"; do
        if [[ "$_version" == "$_ov" ]]; then
            _found=1
            break
        fi
    done

    if [ $_found -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

function docker_mount_params() {
    # $1: warning if not exists
    # $2: warning message
    # $3: output var
    # $@: dirs
    _warning="$1"
    shift
    _warning_message="$1"
    shift
    _out="$1"
    shift

    # generate params
    _mount_params=""
    for _dir in $@;do
        if [ -e "$_dir" ];then
            _mount_params="${_mount_params} -v $_dir:$_dir"
        else
            if [ "$_warning" == "true" ]; then
                echo -e "\e[93mWARNING!! $_warning_message \"$_dir\"\e[0m"
            fi
        fi
    done

    # output
    eval $_out="\$_mount_params"
}

# init parameters
PARAM_OS_VERSION=20.04
AVAILABLE_VERSIONS=($(docker image list | awk '$1=="aosp_env"{print $2}' | sort))

# get parameters
while [ $# -ge 1 ]; do
    case $1 in
        -ov | --os_version)
            shift
            if [ $# -lt 1 ]; then
                echo "os version not provided"
                show_help
                exit 1
            fi

            # check whether version is available
            parse_os_version "$1" "${AVAILABLE_VERSIONS[@]}"
            if [ $? -ne 0 ]; then
                echo "invalid os version. should be in (${AVAILABLE_VERSIONS[@]})"
                exit 1
            fi
            PARAM_OS_VERSION="$1"
            ;;
        *)
            # assume it's os version
            parse_os_version "$1" "${AVAILABLE_VERSIONS[@]}"
            if [ $? -ne 0 ]; then
                echo "invalid os version. should be in (${AVAILABLE_VERSIONS[@]})"
                exit 1
            fi
            PARAM_OS_VERSION="$1"
    esac

    # next
    shift
done

# init env
IMAGE_NAME="aosp_env:${PARAM_OS_VERSION}"
CONTAINER_HOSTNAME="aosp-${PARAM_OS_VERSION/./_}"

# mount prebuilds
PREBUILD_DIRS=(
    "/tools_1604"
    "/Tools"
    "/pkg"
    "/usr/qcom"
)
docker_mount_params true "prebuild not exits. You may not able to build some projects. path:" MOUNT_PREBUILD ${PREBUILD_DIRS[@]}

# mount repo
REPO_PATH=(
    "/usr/bin/repo"
)
docker_mount_params false "" MOUNT_REPO ${REPO_PATH[@]}

# start docker
echo ">> starting env with os version ${PARAM_OS_VERSION}"
docker run --rm -it \
           -e ENV_UID=$(id -u) \
           -e ENV_UNAME="$(id -un)" \
           -e ENV_GID=$(id -g) \
           -e ENV_GNAME="$(id -gn)" \
           -e ENV_HOME="${HOME}" \
           -v "${HOME}":"${HOME}" \
           ${MOUNT_PREBUILD} \
           ${MOUNT_REPO} \
           --network host \
           --hostname "${CONTAINER_HOSTNAME}" \
           --ulimit nofile=65536:65536 \
           "${IMAGE_NAME}" \
           $@

