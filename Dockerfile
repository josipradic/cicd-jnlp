ARG JNLP_IMAGE_TAG=4.10-3-alpine-jdk11

FROM jenkins/inbound-agent:$JNLP_IMAGE_TAG
LABEL Maintainer "Josip Radic <josip.radic@gmail.com>"
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols and that provides following tools: j2cli, awscli, docker cli, docker-compose, kubectl and helm" Vendor="Josip Radic" Version=$JNLP_IMAGE_TAG

# switch to root
USER root

# debian env vars
ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl
ENV LANG=en_US.UTF-8
ENV GOPATH=/

# docker env vars
ENV DOCKER_HOST=${DOCKER_HOST:-tcp://localhost:2376}
ENV DOCKER_DRIVER=${DOCKER_DRIVER:-overlay2}
ENV DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY:-1}
ENV DOCKER_TLS_CERTDIR=${DOCKER_TLS_CERTDIR:-/usr/local/share/ca-certificates}
ENV DOCKER_CERT_PATH=${DOCKER_CERT_PATH:-$DOCKER_TLS_CERTDIR}

RUN \
    echo "Installing dependencies and locales ..." && \
        apk update && \
        DEBIAN_FRONTEND=noninteractive apk add --no-cache \
        curl go cmake make musl-dev gcc gettext-dev libintl && \
        cd /tmp && git clone https://github.com/rilian-la-te/musl-locales.git && \
        cd /tmp/musl-locales && cmake . && make && make install

RUN \
    echo "Installing docker ..." && \
        apk add --no-cache \
        docker && \
    echo "Installing docker-compose ..." && \
        apk add --no-cache \
        py-pip python3-dev libffi-dev openssl-dev libc-dev && \
        pip3 install --upgrade pip && \
        pip install docker-compose && \
    echo "Installing dotnet ..." && \
        pip install python-dotenv[cli] && \
    echo "Installing aws ..." && \
        pip install awscli && \
    echo "Installing j2 ..." && \
        pip install j2cli && \
    echo "Installing yq ..." && \
        wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64" && \
        chmod +x /usr/local/bin/yq && \
    echo "Cleaning up ..." && \
        rm -rf \
            /tmp/* \
            /var/tmp/* \
            /var/cache/apk/*

RUN \
    echo "Installing helm ..." && \
        curl -Ssl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
        chmod 700 get_helm.sh && \
        ./get_helm.sh && \
        rm -f get_helm.sh && \
    \
    echo "Installing kubectl ..." && \
        curl -SslLO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
        chmod 755 kubectl && \
        mv kubectl /usr/local/bin/kubectl
RUN \
    echo "Installing kompose ..." && \
        curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.1/kompose-linux-amd64 -o kompose && \
        chmod +x kompose && \
        mv ./kompose /usr/local/bin/kompose

COPY kompose-1.20.0-patch.sh /usr/local/bin/kompose-1.20.0-patch
COPY kompose-1.21.0-patch.sh /usr/local/bin/kompose-1.21.0-patch
COPY kompose-1.26.1-patch.sh /usr/local/bin/kompose-patch
COPY knsk.sh /usr/local/bin/knsk
RUN \
    echo "Installing kompose patch ..." && \
        chmod +x /usr/local/bin/kompose-patch && \
    echo "Installing knsk kubernetes namespace killer ..." && \
        chmod +x /usr/local/bin/knsk

# switch to jenkins
USER jenkins

ENTRYPOINT ["jenkins-slave"]