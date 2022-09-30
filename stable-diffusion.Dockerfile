# docker build -t drew6017/stable-diffusion -f stable-diffusion.Dockerfile .
# docker run --gpus all -p 8080:8080 -v C:\host\pathtomodelsdir:/sd/models/ --rm -it drew6017/stable-diffusion bash
# python launch.py --listen --port 8080
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt update && \
    apt install -yqq --no-install-recommends git libgl1-mesa-glx libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# install miniconda
ENV MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    MINICONDA_DIR=/opt/miniconda
ADD $MINICONDA_URL /tmp/miniconda-install.sh
WORKDIR /tmp
RUN chmod +x miniconda-install.sh && \
    ./miniconda-install.sh -bfp $MINICONDA_DIR && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# setup conda env
RUN source $MINICONDA_DIR/bin/activate && \
    conda create -y --name sd python=3.10 && \
    conda activate sd && \
    echo "source $MINICONDA_DIR/bin/activate && conda activate sd" >> ~/.bashrc

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /sd && \
    cd /sd && \
    git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
    git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
    git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && \
    git clone https://github.com/salesforce/BLIP.git repositories/BLIP && \
    git clone https://github.com/crowsonkb/k-diffusion repositories/k-diffusion && \
    git clone https://github.com/TencentARC/GFPGAN repositories/GFPGAN && \
    git clone https://github.com/Hafiidz/latent-diffusion repositories/latent-diffusion

WORKDIR /sd
RUN source $MINICONDA_DIR/bin/activate && \
    conda activate sd && \
    pip install --prefer-binary torch transformers==4.19.2 diffusers invisible-watermark numpy

RUN source $MINICONDA_DIR/bin/activate && \
    conda activate sd && \
    pip install -r repositories/CodeFormer/requirements.txt --prefer-binary && \
    pip install -r repositories/k-diffusion/requirements.txt --prefer-binary && \
    pip install -r repositories/GFPGAN/requirements.txt --prefer-binary && \
    pip install -r requirements.txt  --prefer-binary

#ADD https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth /sd/models/GFPGANv1.4.pth
#ENV HUGGING_FACE_TOKEN=""
#ENV SD_MODEL_URL=https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4-full-ema.ckpt
#RUN wget --header "Authorization: Bearer $HUGGING_FACE_TOKEN" $SD_MODEL_URL -O /sd/model.ckpt
