FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV FLUTTER_VERSION=3.29.3

ENV ANDROID_SDK_ROOT=/root/android-sdk
# The PATH variable will be set AFTER the actual installation of cmdline-tools;latest.
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install necessary system packages, Java, build tools, and libraries
RUN apt-get update && apt-get install -y \
    curl wget git unzip xz-utils openjdk-17-jdk \
    build-essential clang cmake ninja-build pkg-config \
    libgtk-3-dev libblkid-dev liblzma-dev libpulse-dev \
    libusb-1.0-0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libfontconfig1 libxrender1 libxi6 libxtst6 libglu1-mesa mesa-common-dev \
    udev usbutils libvirt-daemon-system bridge-utils libvirt-clients \
    qemu-kvm virt-manager \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter SDK (as Root, to /flutter directory)
RUN FLUTTER_DL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" && \
    wget $FLUTTER_DL_URL -O /tmp/flutter.tar.xz && \
    mkdir /flutter && \
    tar -xJf /tmp/flutter.tar.xz --strip-components=1 -C /flutter && \
    rm /tmp/flutter.tar.xz

# Mark /flutter directory as safe for Git (fixes error when running as root)
RUN git config --global --add safe.directory /flutter

# --- Android SDK Command-line Tools Installation (Robust Method) ---
# 1. Download and extract to a temporary directory (just to get sdkmanager running)
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools-temp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O /tmp/cmdline.zip && \
    unzip -q /tmp/cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools-temp/ && \
    rm /tmp/cmdline.zip

# 2. Use the temporary sdkmanager to install the REAL command-line tools and other core SDK components.
#    Explicitly specify the SDK root path for sdkmanager.
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools-temp/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "cmdline-tools;latest" \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "emulator" \
    "system-images;android-34;google_apis;x86_64" \
    "cmake;3.22.1"

# 3. Clean up temporary files and directories
RUN rm -r ${ANDROID_SDK_ROOT}/cmdline-tools-temp

# --- NDK and Licenses ---
# Install Android NDK (Previous error indicated specific version needed)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "ndk;26.3.11579264" --channel=3

# Accept Android SDK licenses
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

# --- AVD Oluşturma ve Flutter Kurulum Sonrası Adımlar ---
# Create AVD
RUN echo "no" | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager create avd -n pixel -k "system-images;android-34;google_apis;x86_64" --device "pixel"

# Flutter precache
RUN /flutter/bin/flutter precache --linux --web --android

# Flutter doctor
RUN /flutter/bin/flutter doctor

# --- Update PATH Environment Variable (Permanent) ---
# Set PATH after ensuring cmdline-tools;latest is installed in the correct location
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:/flutter/bin"

# Set working directory for the project
WORKDIR /app

CMD ["tail", "-f", "/dev/null"]