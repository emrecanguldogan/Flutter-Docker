FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV FLUTTER_VERSION=3.29.3

ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:/flutter/bin"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl wget git unzip xz-utils openjdk-17-jdk \
    build-essential clang cmake ninja-build pkg-config \
    libgtk-3-dev libblkid-dev liblzma-dev libpulse-dev \
    libusb-1.0-0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libfontconfig1 libxrender1 libxi6 libxtst6 libglu1-mesa mesa-common-dev \
    udev usbutils libvirt-daemon-system bridge-utils libvirt-clients \
    qemu-kvm virt-manager \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter
RUN FLUTTER_DL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" && \
    wget $FLUTTER_DL_URL -O /tmp/flutter.tar.xz && \
    mkdir /flutter && \
    tar -xJf /tmp/flutter.tar.xz --strip-components=1 -C /flutter && \
    rm /tmp/flutter.tar.xz

RUN git config --global --add safe.directory /flutter

# Android SDK and emulator tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O /tmp/cmdline.zip && \
    unzip /tmp/cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/ && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline.zip

# Install SDK components
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "cmdline-tools;latest" \
    "emulator" \
    "system-images;android-34;google_apis;x86_64"

RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

# Create AVD
RUN echo "no" | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager create avd -n pixel -k "system-images;android-34;google_apis;x86_64" --device "pixel"

# Flutter precache
RUN /flutter/bin/flutter precache --linux --web --android

# Flutter doctor
RUN /flutter/bin/flutter doctor

WORKDIR /app

CMD ["tail", "-f", "/dev/null"]