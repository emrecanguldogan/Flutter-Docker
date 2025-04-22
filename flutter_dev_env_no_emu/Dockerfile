FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

ENV FLUTTER_VERSION 3.29.3

# SDK Yolları Root'a ayarlandı
ENV ANDROID_SDK_ROOT /root/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:/flutter/bin"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Gerekli sistem paketlerini, Java'yı, build araçlarını ve kütüphaneleri yükle
RUN apt-get update && apt-get install -y curl wget git unzip xz-utils openjdk-17-jdk build-essential clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev liblzma-dev libpulse-dev libusb-1.0-0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libfontconfig1 libxrender1 libxi6 libxtst6 libglu1-mesa mesa-common-dev udev usbutils && rm -rf /var/lib/apt/lists/*

# Flutter SDK'yı indir ve kur (Root olarak, /flutter dizinine)
RUN FLUTTER_DL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" && \
    wget $FLUTTER_DL_URL -O /tmp/flutter.tar.xz && \
    mkdir /flutter && \
    tar -xJf /tmp/flutter.tar.xz --strip-components=1 -C /flutter && \
    rm /tmp/flutter.tar.xz

# Git'in /flutter dizinini güvenli olarak işaretle (root olarak çalışırken çıkan hatayı düzeltir)
RUN git config --global --add safe.directory /flutter

# Android SDK komut satırı araçlarını indir ve kur (Root olarak, /root/android-sdk dizinine)
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-12700392_latest.zip -O /tmp/commandlinetools.zip && \
    unzip /tmp/commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/ && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/commandlinetools.zip

# Gerekli Android SDK bileşenlerini yükle ve lisansları kabul et (Root olarak)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "cmdline-tools;latest"

# Android SDK lisanslarını kabul et (Root olarak)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

# Flutter precache (Root olarak)
RUN /flutter/bin/flutter precache --linux --web --android

# Flutter doctorı tekrar çalıştır (Root olarak)
RUN /flutter/bin/flutter doctor

# Proje dizini için çalışma dizinini ayarla
WORKDIR /app

CMD ["tail", "-f", "/dev/null"]
