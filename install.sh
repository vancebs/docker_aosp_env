#! /bin/bash

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

mkdir -p /opt/bin
cp "$SCRIPT_DIR/start_env.sh" /opt/bin/aosp_env.sh

echo "export PATH=\"/opt/bin:\$PATH\"" > /etc/profile.d/aosp_env.sh
