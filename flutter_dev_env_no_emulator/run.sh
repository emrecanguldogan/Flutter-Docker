#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Grant X11 access
echo "Granting X11 access..."
xhost +local:docker

# Removed getting host user UID and GID (XDG_RUNTIME_DIR is no longer used)

echo "Starting flutter-dev-container container..."

docker compose up --build -d

if [ $? -eq 0 ]; then
    echo "Container started successfully: flutter-dev-container"
    echo "To connect with VS Code:"
    echo "1. Open VS Code."
    echo "2. Run the 'Remote-Containers: Attach to Running Container...' command (Ctrl+Shift-P or F1)."
    echo "3. Select 'flutter-dev-container' from the list."
    echo ""
    # --- IMPORTANT SECURITY WARNING ---
    echo "--- WARNING: HIGH SECURITY RISK ---"
    echo "In this setup, EVERYTHING INSIDE the container RUNS AS ROOT."
    echo "The container is also in PRIVILEGED mode and has almost full authority over your host machine."
    echo "This configuration carries a HIGH SECURITY RISK."
    echo "Files created inside the container will be owned by root on your host and will require 'sudo'."
    echo "---------------------------------"
    echo ""
    echo "When exiting, stop the container by running the 'docker compose down' command."
    echo "For security, remember to revoke X11 access with the 'xhost -local:docker' command in the terminal when you are done!"
else
    echo "Error: Container failed to start."
    echo "You can run 'docker compose logs' for details."
fi