FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ENV FLUTTER_VERSION=3.29.3

# SDK paths set to Root
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:/flutter/bin"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install necessary system packages, Java, build tools, and libraries
RUN apt-get update && apt-get install -y curl wget git unzip xz-utils openjdk-17-jdk build-essential clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev liblzma-dev libpulse-dev libusb-1.0-0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libfontconfig1 libxrender1 libxi6 libxtst6 libglu1-mesa mesa-common-dev udev usbutils && rm -rf /var/lib/apt/lists/*

# Download and install Flutter SDK (as Root, to /flutter directory)
RUN FLUTTER_DL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" && \
    wget $FLUTTER_DL_URL -O /tmp/flutter.tar.xz && \
    mkdir /flutter && \
    tar -xJf /tmp/flutter.tar.xz --strip-components=1 -C /flutter && \
    rm /tmp/flutter.tar.xz

# Mark /flutter directory as safe for Git (fixes error when running as root)
RUN git config --global --add safe.directory /flutter

# Download and install Android SDK command-line tools (As Root, to /root/android-sdk directory)
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O /tmp/commandlinetools.zip && \
    unzip /tmp/commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/ && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/commandlinetools.zip

# Install necessary Android SDK components and accept licenses (As Root)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "cmdline-tools;latest"

# Accept Android SDK licenses (As Root)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

# Flutter precache (As Root)
RUN /flutter/bin/flutter precache --linux --web --android

# Run flutter doctor again (As Root)
RUN /flutter/bin/flutter doctor

# Set working directory for the project
WORKDIR /app

CMD ["tail", "-f", "/dev/null"]