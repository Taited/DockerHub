ARG UBUNTU_VER=20.04
ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG PY_VER=3.8.11
ARG USER=tedsun

FROM nvidia/cuda:10.2-cudnn8-runtime-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive

# Fix source error of Nvidia
#RUN rm /etc/apt/sources.list.d/cuda.list \
#    && rm /etc/apt/sources.list.d/nvidia-ml.list \
#    && apt-key del 7fa2af80 \
#    && apt-get update && apt-get install -y --no-install-recommends wget \
#    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb \
#    && dpkg -i cuda-keyring_1.0-1_all.deb
#ADD https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb .
#RUN dpkg -i cuda-keyring_1.0-1_all.deb

# System packages
RUN apt-get update \
    && apt-get -y install git \
    && apt-get -yq install curl wget jq vim sudo

# Add User
RUN echo "root:tedsun123" | chpasswd

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
    && . /root/.bashrc
#    && conda create -n open-mmlab python=3.8 -y \
#    && conda activate open-mmlab \
#    && conda install pytorch==1.10.1 \
#    torchvision==0.11.2 \
#    torchaudio==0.10.1 \
#    cudatoolkit=11.3 -c pytorch -c conda-forge -y \
#    && pip3 install openmim \
#    && mim install mmcv-full

# Config SSH
RUN git clone https://github.com/Taited/DockerHub \
    && apt-get install openssh-server -y\
    && mkdir /root/.ssh \
    && cat ./DockerHub/A100_ted.pub >> /root/.ssh/authorized_keys \
    && chmod 777 /etc/ssh/sshd_config \
    && rm /etc/ssh/sshd_config \
    && mv ./DockerHub/sshd_config /etc/ssh/ \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/authorized_keys \
    && service ssh start \
    && touch /root/startup_run.sh \
    && chmod +x /root/startup_run.sh \
    && echo "#!/bin/bash" >> /root/startup_run.sh \
    && echo "LOGTIME=$(date \"+%Y-%m-%d %H:%M:%S\")" >> /root/startup_run.sh \
    && echo "echo \"[$LOGTIME] startup run...\" >>/root/startup_run.log" >> /root/startup_run.sh\
    && echo "service ssh start >>/root/startup_run.log" >> /root/startup_run.sh \
    && echo "if [ -f /root/startup_run.sh ]; then" >> /root/.bashrc \
    && echo "    ./root/startup_run.sh" >> /root/.bashrc \
    && echo "fi" >> /root/.bashrc
