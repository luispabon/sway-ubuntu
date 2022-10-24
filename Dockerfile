FROM ubuntu:kinetic

ARG NON_PRIVILEGED_USER=yolo

RUN apt-get update && \
    apt-get install -y \
        git \
        lsb-release \
        make \
        sudo

RUN echo "${NON_PRIVILEGED_USER} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${NON_PRIVILEGED_USER}

RUN adduser ${NON_PRIVILEGED_USER} && \
    adduser ${NON_PRIVILEGED_USER} sudo

USER ${NON_PRIVILEGED_USER}
