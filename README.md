# cicd-jnlp
[![Build Status](https://img.shields.io/docker/stars/josipradic/cicd-jnlp)](https://hub.docker.com/r/josipradic/cicd-jnlp) [![Build Status](https://img.shields.io/docker/pulls/josipradic/cicd-jnlp)](https://hub.docker.com/r/josipradic/cicd-jnlp) [![Build Status](https://img.shields.io/docker/cloud/automated/josipradic/cicd-jnlp)](https://hub.docker.com/r/josipradic/cicd-jnlp) [![Build Status](https://img.shields.io/docker/cloud/build/josipradic/cicd-jnlp)](https://hub.docker.com/r/josipradic/cicd-jnlp) [![Build Status](https://img.shields.io/github/v/tag/josipradic/cicd-jnlp)](https://github.com/josipradic/cicd-jnlp/releases)

A docker image based on [Jenkins JLNP slave](https://hub.docker.com/r/jenkins/jnlp-slave/) agent powered by handy tools used in CICD:
- `docker`
- `docker-compose`
- `dotnet`
- `kubectl`
- `helm`
- `kompose`
- `kompose patches`
- `knsk`
- `aws`
- `j2`
- `yq`

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