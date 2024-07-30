#FROM debian:bookworm-slim
FROM hashicorp/terraform:1.9.2 as terraform
FROM google/cloud-sdk:slim

COPY --from=terraform /bin/terraform /bin/terraform

RUN apt update -y
RUN apt upgrade -y

RUN apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git


RUN cd ~/ && wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
RUN cd ~/ && tar -xf Python-3.12.0.tgz
RUN ls ~/
RUN cd ~/Python-3.12.0 && ./configure --enable-optimizations
RUN cd ~/Python-3.12.0 && make -j 8
RUN cd ~/Python-3.12.0 && make altinstall

RUN pip3.12 install poetry==1.4.2
RUN pip3.12 install --upgrade pip