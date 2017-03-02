FROM node:5.12-slim
#MAINTAINER Ryan J. McDonough "ryan@damnhandy.com"
MAINTAINER Raul Sanchez <rawmind@gmail.com>

ENV SERVICE_HOME=/opt/cloud9 \
    SERVICE_URL=https://github.com/c9/core.git \
    SERVICE_WORK=/workspace \
    GOPATH=/workspace

RUN mkdir -p $SERVICE_HOME $SERVICE_WORK && \
    apt-get update && \
    apt-get install -y python build-essential g++ libssl-dev apache2-utils git libxml2-dev && \
    git clone $SERVICE_URL $SERVICE_HOME && \
    cd $SERVICE_HOME && \
    scripts/install-sdk.sh && \
    sed -i -e 's_127.0.0.1_0.0.0.0_g' $SERVICE_HOME/configs/standalone.js && \
    apt-get autoremove -y python build-essential libssl-dev g++ libxml2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ENV GOLANG_VERSION 1.8
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz
RUN echo "PATH=$PATH:/usr/local/go/bin:/workdir/bin" >> ~/.bashrc
ADD root /
RUN chmod +x /tmp/*.sh 

WORKDIR /workdir
EXPOSE 8080

ENTRYPOINT ["/tmp/start.sh"]
CMD ["--listen 0.0.0.0 --collab -a gophercon:gophercon -p 8080 -w /workspace"] 
