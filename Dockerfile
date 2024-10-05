# Use the TI Robotics SDK's ROS2 Humble base image
FROM robotics-sdk:10.0.0-humble-j721e

# Set non-interactive mode for APT
ARG DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update && apt-get upgrade -y

# Install necessary dependencies
RUN apt-get install -y \
    gnupg2 \
    curl \
    lsb-core \
    vim \
    wget \
    python3-pip \
    libpng16-16 \
    libjpeg-turbo8 \
    libtiff5 \
    cmake \
    build-essential \
    git \
    unzip \
    pkg-config \
    python3-dev \
    python3-numpy \
    libgl1-mesa-dev \
    libglew-dev \
    libeigen3-dev \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtk-3-dev \
    ros-humble-pcl-ros \
    tmux \
    ros-humble-nav2-common \
    x11-apps \
    nano

# Clean up APT cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Build OpenCV from source
RUN cd /tmp && \
    git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.4.0 && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_TESTS=OFF \
          -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/opencv

# Build Pangolin from source
RUN cd /tmp && \
    git clone https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \
    git checkout v0.9.1 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_CXX_FLAGS=-std=c++14 \
          -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/Pangolin

# (Optional) Install VSCode or other tools if needed for development
# COPY ./container_root/shell_scripts/vscode_install.sh /root/
# RUN cd /root/ && chmod +x * && ./vscode_install.sh && rm -rf vscode_install.sh

# Set up ORB-SLAM3
# Create a user 'orb' to run ORB-SLAM3 (optional but recommended for security)
RUN useradd -m -s /bin/bash orb && \
    echo "orb:orb" | chpasswd && \
    adduser orb sudo

# Switch to the 'orb' user
USER orb
WORKDIR /home/orb

# Clone ORB-SLAM3 repository
RUN git clone https://github.com/Mauhing/ORB_SLAM3.git ORB_SLAM3

# Build ORB-SLAM3
RUN cd ORB_SLAM3 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

# (Optional) Define entrypoint or default command
# CMD ["bash"]
