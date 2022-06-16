FROM ubuntu:bionic
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ bionic main universe" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ bionic-updates main universe" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ bionic-security main universe" >> /etc/apt/sources.list 
RUN apt update && apt -y install build-essential git snapcraft ubuntu-image && apt-get -y build-dep livecd-rootfs
RUN git clone --depth 1 https://github.com/ivanhu5866/uefi-aarch64-gadget && \
    cd uefi-aarch64-gadget && snapcraft prime
RUN git clone --depth 1 https://github.com/ivanhu5866/fwts-livecd-rootfs.git && \
    cd fwts-livecd-rootfs && debian/rules binary && \
    dpkg -i ../livecd-rootfs_*_arm64.deb
VOLUME /image
ENTRYPOINT ubuntu-image classic -a arm64 -d -p ubuntu-cpc -s jammy -O /image \
    --extra-ppas firmware-testing-team/ppa-fwts-stable uefi-aarch64-gadget/prime && \
    fwts_version=$(apt-cache show fwts | grep ^Version | egrep -o '[0-9]{2}.[0-9]{2}.[0-9]{2}' | sort -r | head -1) && \
    xz /image/arm64.img
