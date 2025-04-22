#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "X11 erişimi veriliyor..."
xhost +local:docker

echo "flutter-dev-container başlatılıyor..."
docker compose up --build -d

if [ $? -eq 0 ]; then
    echo "Başarılı! VS Code ile bağlanabilirsin."
    echo "Emülatörü başlatmak için konteyner içinde şu komutu çalıştır:"
    echo ""
    echo "    emulator -avd pixel -gpu swiftshader_indirect -no-audio -no-boot-anim"
    echo ""
    echo "Sonrasında Flutter uygulamanı şu komutla çalıştırabilirsin:"
    echo ""
    echo "    flutter run"
else
    echo "Başlatılamadı. Logları kontrol et: docker compose logs"
fi

