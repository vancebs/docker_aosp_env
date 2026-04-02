#! /bin/bash

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

function show_help() {
    echo "Build docker image for AOSP build env"
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

# init parameters
PARAM_OS_VERSION=20.04
AVAILABLE_VERSIONS=($(ls Dockerfile.* | sed 's/Dockerfile.//g' | sort))

# get parameters
while [ $# -ge 1 ]; do
    case $1 in
        -ov | --os_version)
            shift
            if [ $# -lt 1 ]; then
                echo "ERROR: wrong parameter"
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
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.${PARAM_OS_VERSION}"
if [ ! -f "${DOCKERFILE}" ]; then
    echo "ubuntu ${PARAM_OS_VERSION} is not supported!!"
    exit 1
fi

IMAGE_NAME="aosp_env:${PARAM_OS_VERSION}"

# print env
echo ">> build with following configure"
echo "==============================="
echo "os version: ${PARAM_OS_VERSION}"
echo "dockerfile: ${DOCKERFILE}"
echo "image name: ${IMAGE_NAME}"
echo "==============================="

# build
echo ">> building ..."
docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
echo ">> building ...Done"
