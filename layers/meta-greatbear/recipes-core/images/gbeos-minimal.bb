IMAGE_FEATURES += "ssh-server-openssh"

LICENSE = "MIT"

LICENSE_FLAGS_ACCEPTED += "commercial"

inherit core-image

#CORE_IMAGE_BASE_INSTALL += "packagegroup-demo-base packagegroup-demo-basetests"
CORE_IMAGE_BASE_INSTALL += "${@'packagegroup-demo-systemd' if d.getVar('VIRTUAL-RUNTIME_init_manager') == 'systemd' else ''}"
#TOOLCHAIN_HOST_TASK += "nativesdk-packagegroup-cuda-sdk-host"
CORE_IMAGE_BASE_INSTALL += "nvidia-docker cuda-libraries cudnn cuda-toolkit cuda-nvml nvidia-container-toolkit"

inherit nopackages

#IMAGE_FEATURES += "splash"

inherit features_check

REQUIRED_DISTRO_FEATURES = "virtualization systemd"

IMAGE_INSTALL:append = " \
    tzdata \
    perl-misc \
    coreutils \
    bash \
    parted \
    curl \
    linux-firmware \
    kernel-modules \
    python3-pip \
    python3-ansible \
    python3-ansible-core \
    python3-jinja2 \
    python3-pyyaml \
    python3-distutils \
    python3-distutils-extra \
    python3-resolvelib \
    python3-pyparsing \
    python3-pycparser \
    python3-packaging \
    python3-cffi \
    python3-cryptography \
    python3-terminal \
    python3-misc \
    sudo \
    keepalived \
    dpkg \
    iscsi-initiator-utils \
    tgt \
    agent \
"
MACHINE_HWCODECS = ""

root_postprocess() {
    rm ${IMAGE_ROOTFS}/etc/systemd/system/sockets.target.wants/docker.socket
    mkdir -p ${IMAGE_ROOTFS}/usr/local/bin
}

ROOTFS_POSTPROCESS_COMMAND += "root_postprocess; "
