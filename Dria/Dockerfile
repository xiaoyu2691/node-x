# Dockerfile
FROM ubuntu:20.04

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y wget unzip curl net-tools

RUN curl -fsSL https://ollama.com/install.sh | bash

RUN mkdir -p /app
RUN mkdir -p /app_conf

WORKDIR /app

RUN wget -O /tmp/dkn-compute-launcher-linux-amd64.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip && \
    unzip /tmp/dkn-compute-launcher-linux-amd64.zip -d /app && \
    rm /tmp/dkn-compute-launcher-linux-amd64.zip

# 替换 .env 文件的脚本
#COPY ./env /app/env
#RUN mv /app/env /app/dkn-compute-node/.env && touch /app/env # 确保有一个默认env 文件
#RUN cp /app/env /app/dkn-compute-node/.env

# 启动命令
CMD ["cd /app/dkn-compute-node && ./dkn-compute-launcher"]