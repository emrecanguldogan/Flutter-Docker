#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# X11 erişimi vermek
echo "X11 erişimi veriliyor..."
xhost +local:docker

# Ana makinenin kullanıcı UID ve GID'sini alma kaldırıldı (XDG_RUNTIME_DIR artık kullanılmıyor)

echo "flutter-dev-container container'ı başlatılıyor..."

docker compose up --build -d

if [ $? -eq 0 ]; then
    echo "Container başarıyla başlatıldı: flutter-dev-container"
    echo "VS Code ile bağlanmak için:"
    echo "1. VS Code'u açın."
    echo "2. 'Remote-Containers: Attach to Running Container...' komutunu çalıştırın (Ctrl+Shift-P veya F1)."
    echo "3. Listeden 'flutter-dev-container'ı seçin."
    echo ""
    # --- ÖNEMLİ GÜVENLİK UYARISI ---
    echo "--- DİKKAT: YÜKSEK GÜVENLİK RİSKİ ---"
    echo "Bu kurulumda container içinde HER ŞEY ROOT olarak ÇALIŞMAKTADIR."
    echo "Container ayrıca PRIVILEGED (ayrıcalıklı) moddadır ve ana makinenize neredeyse tam yetkiye sahiptir."
    echo "Bu yapılandırma YÜKSEK GÜVENLİK RİSKİ taşır."
    echo "Container içinde oluşturulan dosyalar ana makinenizde root'a ait olacak ve 'sudo' gerektirecektir."
    echo "---------------------------------"
    echo ""
    echo "Çıkış yaparken 'docker compose down' komutunu çalıştırarak container'ı durdurun."
    echo "Güvenlik için işiniz bittiğinde terminalde 'xhost -local:docker' komutu ile X11 iznini geri almayı unutmayın!"
else
    echo "Hata: Container başlatılamadı."
    echo "Detaylar için 'docker compose logs' komutunu çalıştırabilirsiniz."
fi
