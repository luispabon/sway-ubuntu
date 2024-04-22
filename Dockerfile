FROM ubuntu:noble

ARG NON_PRIVILEGED_USER=yolo

RUN apt-get update && \
    apt-get install -y \
        git \
        lsb-release \
        make \
        sudo

RUN useradd -m ${NON_PRIVILEGED_USER} && \
    echo "${NON_PRIVILEGED_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${NON_PRIVILEGED_USER}

USER ${NON_PRIVILEGED_USER}
