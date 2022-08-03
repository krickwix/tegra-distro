IMAGE_FEATURES += "ssh-server-openssh"

LICENSE = "MIT"

LICENSE_FLAGS_ACCEPTED += "commercial"

inherit core-image

CORE_IMAGE_BASE_INSTALL += "packagegroup-demo-base packagegroup-demo-basetests"
CORE_IMAGE_BASE_INSTALL += "${@'packagegroup-demo-systemd' if d.getVar('VIRTUAL-RUNTIME_init_manager') == 'systemd' else ''}"
TOOLCHAIN_HOST_TASK += "nativesdk-packagegroup-cuda-sdk-host"

inherit nopackages

IMAGE_FEATURES += "splash x11-base hwcodecs"

inherit features_check

REQUIRED_DISTRO_FEATURES = "x11 opengl virtualization"

CORE_IMAGE_BASE_INSTALL += "packagegroup-demo-x11tests"
CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'vulkan', 'packagegroup-demo-vulkantests', '', d)}"
CORE_IMAGE_BASE_INSTALL += "libvisionworks-devso-symlink nvidia-docker cuda-libraries tegra-mmapi-tests vpi1-tests tensorrt-tests"

IMAGE_INSTALL:append = " tzdata python3-pip perl-misc \
    bash parted curl k3s \
    linux-firmware kernel-modules \
    python3-ansible \
    python3-distutils python3-distutils-extra \
    keepalived dpkg \
"