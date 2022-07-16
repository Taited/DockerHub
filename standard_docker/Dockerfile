ARG PYTORCH="1.8.0"
ARG CUDA="11.1"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel
ENV DEBIAN_FRONTEND noninteractive
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV FORCE_CUDA="1"

# Fix source error of Nvidia
RUN rm /etc/apt/sources.list.d/cuda.list \
    && rm /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-key del 7fa2af80 \
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb.1 \
    && rm cuda-keyring_1.0-1_all.deb \
    $$ rm cuda-keyring_1.0-1_all.deb.1

# System packges
RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get -y install git \
    && apt-get -yq install curl wget jq vim sudo

# Install MMCV
RUN pip install mmcv-full==1.3.16 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.8.0/index.html

# Add User
RUN echo "root:tedsun123" | chpasswd

ENV PATH /opt/conda/bin:$PATH
RUN /opt/conda/bin/conda init bash \
    && . /root/.bashrc

RUN conda clean --all
RUN git clone https://github.com/open-mmlab/mmgeneration.git /mmgen
WORKDIR /mmgen
ENV FORCE_CUDA="1"
RUN pip install -r requirements.txt
RUN pip install --no-cache-dir -e .
WORKDIR /root
RUN rm -rf /mmgen

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
    && echo "    /root/startup_run.sh" >> /root/.bashrc \
    && echo "fi" >> /root/.bashrc
