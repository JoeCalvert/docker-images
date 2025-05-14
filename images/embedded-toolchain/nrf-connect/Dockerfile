
ARG BASE_IMAGE="ubuntu:22.04"

FROM ${BASE_IMAGE}
ARG NRF_CONNECT_SDK_VERSION
ARG NRF_UDEV_VERSION
ARG JLINK_TOOLS_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install prerequisites
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git cmake ninja-build gperf \
    python3-dev python3-venv python3-pip python3-setuptools python3-tk python3-wheel \
    xz-utils file ccache dfu-util device-tree-compiler wget \
    make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 && \
    rm -rf /var/lib/apt/lists/*

# Download dependencies
ARG NRF_UDEV_VERSION
ARG JLINK_TOOLS_VERSION
RUN mkdir -p /opt/ncs-deps && \
    wget -O /opt/ncs-deps/jlink-tools.deb --post-data "accept_license_agreement=accepted" "https://www.segger.com/downloads/jlink/JLink_Linux_${JLINK_TOOLS_VERSION}_x86_64.deb" && \
    wget -O /opt/ncs-deps/nrf-udev.deb "https://github.com/NordicSemiconductor/nrf-udev/releases/download/v${NRF_UDEV_VERSION}/nrf-udev_${NRF_UDEV_VERSION}-all.deb" && \
    wget -O /opt/ncs-deps/nrfutil "https://files.nordicsemi.com/ui/api/v1/download?repoKey=swtools&path=external/nrfutil/executables/x86_64-unknown-linux-gnu/nrfutil&isNativeBrowsing=false"

# Install dependencies
RUN apt-get update && \
    dpkg --unpack /opt/ncs-deps/jlink-tools.deb &&  \
    rm -f /var/lib/dpkg/info/jlink.postinst && \
    apt-get install -yf && \
    apt-get install -y --no-install-recommends /opt/ncs-deps/nrf-udev.deb && \
    cp /opt/ncs-deps/nrfutil /usr/bin/nrfutil && \
    chmod +x /usr/bin/nrfutil && \
    rm -rf /var/lib/apt/lists/*

# Install nRF Connect Toolchain
ARG NRF_CONNECT_SDK_VERSION
RUN mkdir -p /opt/ncs && \
    nrfutil install sdk-manager && \
    nrfutil sdk-manager config install-dir set /opt/ncs && \
    nrfutil sdk-manager toolchain install --ncs-version ${NRF_CONNECT_SDK_VERSION}

# Create python venv and install West
RUN python3 -m venv /opt/ncs/.venv && \
    . /opt/ncs/.venv/bin/activate && \
    pip3 install west

# Download nRF Connect SDK
RUN . /opt/ncs/.venv/bin/activate && \
    mkdir /opt/ncs/nrf && \
    cd /opt/ncs/nrf && \
    nrfutil sdk-manager toolchain launch --ncs-version ${NRF_CONNECT_SDK_VERSION} --shell && \
    west init -m https://github.com/nrfconnect/sdk-nrf --mr ${NRF_CONNECT_SDK_VERSION} ${NRF_CONNECT_SDK_VERSION}

RUN . /opt/ncs/.venv/bin/activate && \
    cd /opt/ncs/nrf/${NRF_CONNECT_SDK_VERSION} && \
    west update && \
    west zephyr-export

# Install nRF Connect SDK dependencies
RUN . /opt/ncs/.venv/bin/activate && \
    cd /opt/ncs/nrf/${NRF_CONNECT_SDK_VERSION} && \
    pip3 install -r zephyr/scripts/requirements.txt && \
    pip3 install -r nrf/scripts/requirements.txt && \
    pip3 install -r bootloader/mcuboot/scripts/requirements.txt

# Install Zephyr SDK
RUN . /opt/ncs/.venv/bin/activate && \
    cd /opt/ncs/nrf/${NRF_CONNECT_SDK_VERSION}/zephyr && \
    west sdk install

ENV ZEPHYR_PATH="/opt/ncs/nrf/${NRF_CONNECT_SDK_VERSION}/zephyr"
ENV NRF_PYTHON_VENV_PATH="/opt/ncs/.venv"
ENV NRF_CONNECT_SDK_PATH="/opt/ncs/nrf/${NRF_CONNECT_SDK_VERSION}"

ENTRYPOINT [ "/opt/ncs/.venv/bin/activate" ]
CMD ["/bin/bash"]