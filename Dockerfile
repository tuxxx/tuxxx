#
# Dockerfile for building TuXXX operating system.
#
# This code is part of TuXXX project
# https://github.com/tuxxx
#

FROM debian:stretch-slim
MAINTAINER github.com/tuxxx

RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
    debootstrap \
    isolinux \
    squashfs-tools \
    xorriso \
    syslinux \
    syslinux-common

COPY . /tuxxx/

WORKDIR /tuxxx

ENTRYPOINT ["/tuxxx/build.sh"]
