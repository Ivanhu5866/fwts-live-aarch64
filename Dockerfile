FROM ubuntu:jammy
COPY --from=snapcore/snapcraft:stable /snap /snap
ENV PATH="/snap/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="arm64"
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy main universe" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy-updates main universe" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy-security main universe" >> /etc/apt/sources.list
RUN apt update && apt -y install build-essential git ubuntu-image && apt-get -y build-dep livecd-rootfs
RUN git clone --depth 1 https://github.com/ivanhu5866/uefi-aarch64-gadget
RUN git clone --depth 1 https://github.com/ivanhu5866/fwts-livecd-rootfs-jammy.git && \
    cd fwts-livecd-rootfs-jammy && debian/rules binary && \
    dpkg -i ../livecd-rootfs_*_arm64.deb
VOLUME /image
ENTRYPOINT ubuntu-image classic -a arm64 -d -p ubuntu-cpc -s jammy -O /image \
    --extra-ppas firmware-testing-team/ppa-fwts-stable uefi-aarch64-gadget/prime && \
    fwts_version=$(apt-cache show fwts | grep ^Version | egrep -o '[0-9]{2}.[0-9]{2}.[0-9]{2}' | sort -r | head -1) && \
    xz /image/arm64.img
