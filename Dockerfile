#
# Dockerfile for building and installing TuXXX operating system.
#
# This code is part of TuXXX project
# https://github.com/tuxxx
#

FROM debian:stretch-slim

RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
    debootstrap \
    genisoimage \
    isolinux \
    squashfs-tools \
    syslinux \
    syslinux-common

COPY . /tuxxx/

WORKDIR /tuxxx

ENTRYPOINT ["/tuxxx/build.sh"]
