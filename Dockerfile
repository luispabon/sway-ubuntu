FROM ubuntu:kinetic

RUN apt-get update && \
    apt-get install -y \
        git \
        make \
        sudo
