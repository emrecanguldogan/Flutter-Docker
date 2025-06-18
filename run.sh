#!/bin/bash

export COMPOSE_BAKE=true

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "Granting X11 access..."
xhost +local:docker

echo "Starting flutter-dev-container..."
docker compose up --build -d

if [ $? -eq 0 ]; then
    echo "Success! You can connect with VS Code."
    echo "To start the pre-configured emulator inside the container, run this command:"
    echo ""
    echo "    /root/android-sdk/emulator/emulator -avd pixel -gpu host -no-audio -no-boot-anim "
    echo ""
    echo "After that, you can run your Flutter application with this command:"
    echo ""
    echo "    flutter run"
else
    echo "Startup failed. Check the logs: docker compose logs"
fi