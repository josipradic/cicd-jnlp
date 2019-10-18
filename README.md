# Jenkins JLNP agent powered with CICD tools
[![Build Status](https://img.shields.io/docker/stars/josipradic/jenkins-jnlp-cicd)](https://hub.docker.com/r/josipradic/jenkins-jnlp-cicd) [![Build Status](https://img.shields.io/docker/pulls/josipradic/jenkins-jnlp-cicd)](https://hub.docker.com/r/josipradic/jenkins-jnlp-cicd) [![Build Status](https://img.shields.io/docker/automated/josipradic/jenkins-jnlp-cicd)](https://hub.docker.com/r/josipradic/jenkins-jnlp-cicd) [![Build Status](https://img.shields.io/docker/build/josipradic/jenkins-jnlp-cicd)](https://hub.docker.com/r/josipradic/jenkins-jnlp-cicd) [![Build Status](https://img.shields.io/github/v/tag/josipradic/jenkins-jnlp-cicd)](https://github.com/josipradic/jenkins-jnlp-cicd/releases/tag/1.0.0)

A docker image based on [Jenkins JLNP slave](https://hub.docker.com/r/jenkins/jnlp-slave/) agent powered by CICD tools:
- `docker`
- `docker-compose`
- `kubectl`
- `helm`
- `kompose`
- `aws`
- `j2`

You can build this image using a docker build argument `JNLP_IMAGE_TAG` and define the tag you want to build from `jenkins/jnlp-slave` original image. It accepts several docker environment variables where you can define docker: host, storage driver, TLS mode and TLS certificate directories. Environment variables are optional with default values:
```
# set as docker dind (docker-in-docker) by default
DOCKER_HOST=tcp://localhost:2376

# overlay2 storage driver
DOCKER_DRIVER=overlay2

# since we're pulling 19.03 docker version, TLS comes by default
DOCKER_TLS_VERIFY=1

# location of certificates taken from docker host
DOCKER_TLS_CERTDIR=/usr/local/share/ca-certificates
DOCKER_CERT_PATH=/usr/local/share/ca-certificates
```

These defaults can be changed every time you execute `docker run` from the created container. If you desire you can turn off TLS or you can switch the docker client to DooD (docker out of docker) mode instead of DinD (docker in docker) which is set by default.

At the time of writing this image is using latest versions of all CICD tools which will be improved in future updates where you will have the choice of choosing which version to pull for each tool in image build process.