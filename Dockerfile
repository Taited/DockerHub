ARG UBUNTU_VER=20.04
ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG PY_VER=3.8.11
ARG USER=tedsun

# FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# System packages
RUN apt-get update \
    && apt-get -y install git \
    && apt-get -yq install curl wget jq vim sudo

# Add User
RUN useradd --create-home --no-log-init --shell /bin/bash tedsun \
    && adduser tedsun sudo \
    && echo "tedsun:tedsun123" | chpasswd

# Config UID and GID
RUN usermod -u 1000 tedsun\
    && usermod -G 1000 tedsun

# Working Directory
WORKDIR /home/tedsun

# Download necessary configs from github
RUN git clone https://github.com/Taited/DockerHub

# Config SSH
RUN apt-get install openssh-server -y\
    && mkdir /home/tedsun/.ssh \
    && cat ./DockerHub/A100_ted.pub >> /home/tedsun/.ssh/autorized_keys 

# Install miniconda to /miniconda
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && /bin/bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && /opt/conda/bin/conda clean -tipsy \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc

# Config env of open-mmlab
ENV PATH /opt/conda/bin:$PATH

RUN /opt/conda/bin/conda init bash \
    && . /root/.bashrc \
    && conda create -n open-mmlab python=3.8 -y \
    && conda activate open-mmlab \
    && conda install pytorch==1.10.1 \
    torchvision==0.11.2 \
    torchaudio==0.10.1 \
    cudatoolkit=11.3 -c pytorch -c conda-forge -y \
    && pip3 install openmim \
    && mim install mmcv-full

# Login User
USER tedsun
# RUN sudo chmod 700 /home/tedsun/.ssh -S \
#     && sudo chmod 600 /home/tedsun/.ssh/autorized_keys -S
# && service start sshd
