#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo ./install.sh)" 
   exit 1
fi

echo "Installing gifygrub to /usr/local/bin..."
install -Dm755 bin/gifygrub /usr/local/bin/gifygrub

echo "Installing libraries to /usr/local/lib/gifygrub..."
install -dm755 /usr/local/lib/gifygrub
install -Dm644 lib/* /usr/local/lib/gifygrub/

echo "Installation complete!"
