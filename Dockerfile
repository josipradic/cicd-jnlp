ARG DOCKER_VERSION
ARG DOCKER_CHANNEL
ARG TINI_VERSION

FROM jenkins/jnlp-slave:3.35-5-alpine
LABEL maintainer "Josip Radic <josip.radic@gmail.com>"
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols and that provides following tools: j2cli, awscli, docker cli, docker-compose, kubectl and helm" Vendor="Josip Radic" Version="3.35-5-alpine"

ENV DOCKER_VERSION=${DOCKER_VERSION:-19.03.2}
ENV DOCKER_CHANNEL=${DOCKER_CHANNEL:-stable}
ENV TINI_VERSION=${TINI_VERSION:-0.18.0}

USER root

# debian packages
RUN apk update && \
    DEBIAN_FRONTEND=noninteractive apk add py2-pip groff

# debian, setting locales
ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl
RUN apk add --update git cmake make musl-dev gcc gettext-dev libintl && \
    cd /tmp && git clone https://github.com/rilian-la-te/musl-locales.git && \
    cd /tmp/musl-locales && cmake . && make && make install

ENV LANG=en_US.UTF-8

# installing required packages
RUN apk add curl iptables

# installing tini
RUN curl -SsLo /usr/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/bin/tini && \
    dos2unix /usr/bin/tini

# install docker cli
RUN curl -Ssl https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz > docker.tar.gz && \
    tar xf docker.tar.gz && \
    chown -R root:root docker && \
    mv docker/* /usr/bin

# install docker-compose
RUN apk add py-pip && \
    apk add python-dev libffi-dev openssl-dev gcc libc-dev make && \
    pip install docker-compose

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 kubectl && \
    mv kubectl /usr/local/bin/kubectl

# install aws cli and j2cli
RUN pip install awscli && \
    pip install j2cli

USER jenkins

ENTRYPOINT ["/usr/bin/tini", "--", "jenkins-slave"]