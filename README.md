# Containerized Flutter & Android Development Environment

## Project Description

This project provides a fully containerized development environment for building Flutter applications, including the necessary Android SDK and emulator setup. By using Docker and Docker Compose, it ensures a consistent and isolated development environment, free from host system dependencies and conflicts.

## ⚠️ Warning

This development environment setup involves configurations that require elevated privileges on the host system and grant the Docker container certain levels of access (such as X11 display access and device mapping like `/dev/kvm`). While necessary for features like the Android emulator GUI and hardware acceleration, these configurations can reduce the isolation between the container and the host and carry potential security implications. Please review the `docker-compose.yml` and the setup script (`start.sh`) carefully and understand the permissions being granted. Refer to the [Issues](#issues) section for a more detailed discussion on elevated privileges required.

## Features

* **Isolated Environment:** Develop in a clean, consistent environment isolated from your host system.
* **Pre-configured SDKs:** Includes the Android SDK, command-line tools, and a specific Java Development Kit (OpenJDK 17).
* **Flutter SDK Included:** Comes with a specified version of the Flutter SDK.
* **Android Emulator Support:** Configured to run an Android emulator with potential GPU acceleration.
* **Physical Device Support (ADB):** Allows connecting a physical Android device via ADB for debugging and running builds.
* **Persistent Caching:** Uses Docker volumes to cache SDKs, Gradle, and Flutter assets for faster build times across container restarts.
* **X11 Forwarding:** Configured to allow graphical applications (like the Android Emulator) to display on your host machine.
* **Optional GPU Acceleration (Nvidia Container Toolkit):** Includes configuration options for leveraging Nvidia GPUs via the Nvidia Container Toolkit. Eventhough Nvidia GPUs cannot be used on android emulation. Refer to the [Issues](#issues) section for further details.

## Prerequisites

Before you begin, ensure you have the following installed on your host machine:

* [**Docker:**](https://www.docker.com/get-started) Docker Engine
* [**Docker Compose:**](https://docs.docker.com/compose/install/) Docker Compose (usually included with newer Docker Desktop installations)
* **VS Code (Recommended):** For connecting to and developing inside the container using the Remote - Containers extension.
    * [Visual Studio Code](https://code.visualstudio.com/)
    * [Remote - Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
* **X server:** If you are on Linux, your desktop environment likely already has one. If on macOS or Windows, you might need an X server application (e.g., VcXsrv for Windows, XQuartz for macOS).
* **Nvidia Container Toolkit (Optional for GPU support):** If you plan to use GPU acceleration in Docker and have an Nvidia GPU. Follow the [official installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

## Getting Started

Follow these steps to set up and run the containerized development environment:

1.  **Clone the Repository:**
    ```bash
    git clone [YOUR_REPOSITORY_URL]
    cd [YOUR_PROJECT_DIRECTORY]
    ```
    Replace `[YOUR_REPOSITORY_URL]` and `[YOUR_PROJECT_DIRECTORY]` with your project's actual URL and directory name.

2.  **Review Configuration:**
    Familiarize yourself with the `Dockerfile` and `docker-compose.yml` files to understand how the environment is built and configured. You can adjust Flutter and SDK versions, volume names, etc., as needed.

3.  **Run the Setup Script:**
    Execute the provided bash script to grant X11 access and build/start the Docker container.

    ```bash
    chmod +x start.sh # Make the script executable if necessary
    ./start.sh
    ```
    This script will:
    * Grant your Docker container access to your host's X server (for GUI applications).
    * Build the Docker image (if not already built) using the `Dockerfile`.
    * Start the `flutter_dev` service defined in `docker-compose.yml` in detached mode (`-d`).

4.  **Verify Container Status:**
    Ensure the container is running:

    ```bash
    docker compose ps
    ```
    You should see `flutter-dev-container_try` listed with a `State` of `running`.

## Using the Development Environment

Once the container is running, you can connect to it and start developing.

1.  **Connect with VS Code:**
    * Open VS Code.
    * Open the Command Palette (Ctrl+Shift+P or Cmd+Shift+P).
    * Search for and select "Remote-Containers: Attach to Running Container...".
    * Choose `flutter-dev-container_try` from the list.
    VS Code will open a new window connected to the inside of your Docker container. Your project files from the host machine should be available under `/app` due to the volume mapping in `docker-compose.yml`.

2.  **Open Integrated Terminal:**
    Inside the VS Code window connected to the container, open a new Integrated Terminal (Ctrl+` or Cmd+`). This terminal runs directly inside the container.

    **Note for Physical Android Devices:**
    If you plan to use a physical Android device for debugging or running builds, ensure the following **before** starting the Docker container:
    * The device is recognized and accessible by your **host** operating system.
    * **USB Debugging** is enabled on your Android device (usually found in Developer Options).
    * You have authorized your host computer for USB debugging when prompted on the device.

3.  **Start the Android Emulator:**
    In the integrated terminal, run the command to start the pre-configured Android emulator:

    ```bash
    emulator -avd pixel -gpu host -no-audio -no-boot-anim
    ```
    *(Note: Adjust `-gpu host` based on your setup and if you have the cpu embedded gpu (It work on intel embedded GPU, probably work on amd also). `swiftshader_indirect` is a software rendering option if GPU acceleration is not working).*

4.  **Run Your Flutter Application:**
    Navigate to your Flutter project directory within the container (likely `/app`) and run your application:

    ```bash
    cd /app
    flutter run
    ```
    If the emulator is running, the application should deploy and run on it. You can also connect a physical Android device to your host machine, and it should be accessible within the container (especially if the `/dev/bus/usb` device is mapped or privileged mode is enabled).

5.  **Install/Push APKs Manually (Optional):**
    If you need to manually install an APK file onto the emulator or a connected device from within the container:

    * **Copy the APK to the Device:**
        ```bash
        adb -s [device_ser_num] push [local_file_path_in_container] [device_path]
        # Example: adb -s emulator-5554 push build/app/outputs/flutter-apk/app-release.apk /sdcard/
        ```
        (Replace `[device_ser_num]` with your emulator/device serial found via `adb devices`).

    * **Install the APK on the Device:**
        ```bash
        adb -s [device_ser_num] install -r [local_apk_path_in_container]
        # Example: adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
        ```
        (The `-r` flag reinstalls, keeping data).

## Configuration

Key configuration points are in `docker-compose.yml` and `Dockerfile`:

* **`Dockerfile`:** Defines the base image, installs system dependencies, downloads and sets up Flutter and Android SDKs, creates the AVD, and sets environment variables. Modify this file to change Flutter/SDK versions or add other system-level tools.
* **`docker-compose.yml`:** Defines the `flutter_dev` service.
    * `build`: Specifies the Dockerfile context and path.
    * `image`/`container_name`: Sets the image and container names.
    * `privileged: true`: Grants extensive capabilities to the container (use with caution).
    * `deploy: resources`: Configures access to hardware resources like GPUs (requires Nvidia Container Toolkit for Nvidia GPUs).
    * `volumes`: Maps host directories/volumes to container paths for code, SDK caches, and X11/KVM access.
    * `environment`: Sets environment variables within the container (e.g., `DISPLAY`, SDK roots, Java home).
    * `devices`: Can be used for explicit device mapping (often redundant with `privileged` or `deploy`).
    * `ports`: For mapping network ports if needed.

Adjust these files to tailor the environment to your specific needs.

## Troubleshooting

* **X11 Forwarding Issues (Emulator GUI not showing):**
    * Ensure the `xhost +local:docker` command ran successfully on your host before starting the container.
    * Verify the `DISPLAY=${DISPLAY}` environment variable is correctly passed to the container.
    * Check your host firewall settings.
    * Try the software rendering option for the emulator: `-gpu swiftshader_indirect`.
* **GPU Acceleration Problems:**
    * Ensure the Nvidia Container Toolkit is correctly installed on your host.
    * Verify the `deploy: resources` section in `docker-compose.yml` is correctly configured and uncommented.
    * Check Docker logs for errors related to GPU access.
* **Container Fails to Start:**
    * Check the Docker Compose logs for the service: `docker compose logs flutter_dev`.
    * Review the `Dockerfile` for potential errors during the build process if `docker compose up --build` failed.

## Issues

This section lists known potential issues or areas for improvement in the current setup.

* **Nvidia GPU Acceleration Reliability:**
    While the Docker Compose file includes configuration for Nvidia GPU access (`deploy: resources`), getting consistent and reliable GPU acceleration for the Android emulator within a Docker container on all host systems and driver versions is quite challenging. Users might still experience performance issues or need further host-specific configuration beyond what is provided. This remains an area that can be sensitive to the host environment setup (Nvidia driver, Docker configuration, etc.).

* **Elevated Privileges Required:**
    Some aspects of this setup, particularly granting X11 access (`xhost +local:docker`) and potentially using the `privileged: true` mode in Docker Compose (although efforts are made to use `deploy: resources` and volume mappings instead), require elevated privileges or root access on the host system. Running containers with high privileges can pose security risks and might not align with security policies in all environments. Exploring less privileged alternatives for hardware access (like user-namespace remapping or more fine-grained capabilities) could be a future improvement area.

* **Android Emulator Compatibility:**
    Compatibility and performance of the Android Emulator within a Docker container can sometimes vary depending on the host operating system, kernel version, and hardware virtualization support (KVM). While `/dev/kvm` is mapped, some users might encounter emulator startup issues or poor performance.

* **Large Image Size:**
    The Docker image includes the full Android SDK, Flutter SDK, JDK, and various system dependencies, resulting in a relatively large image size. Optimizing the Dockerfile to reduce the final image size could be beneficial.

* **Manual X11 Access Step:**
    The current setup requires manually running `xhost +local:docker` on the host before starting the container. Automating or finding alternative methods for granting X11 access without this manual step could improve usability.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Feel free to fork the repository, open issues, or submit pull requests if you have suggestions or improvements.