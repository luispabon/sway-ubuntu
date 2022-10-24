FROM ubuntu:kinetic


RUN apt-get update && \
    apt-get install -y \
        git \
        make \
        sudo

ARG USERNAME=yolo

RUN echo "${USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USERNAME}

RUN adduser ${USERNAME} && \
    adduser ${USERNAME} sudo

USER ${USERNAME}
