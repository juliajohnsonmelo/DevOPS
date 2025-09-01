#!/bin/bash

#cria rede
docker network create jenkins

#cria conteiner para isolar o docker
docker run \
	--name jenkins-docker \
	--rm \
	--detach \
	--privileged \
	--network jenkins \
	--network-alias docker \
	--env DOCKER_TLS_CERTDIR=/certs \
	--volume jenkins-docker-certs:/certs/client \
	--colume jenkins-data:/vat/jenkins_home \
	--publish 2376:2376 \
	docker:dind \
	--storage-driver overlay2
	
#faz o build da imagem do jenkins
docker build -t meu-jenkins

#executa a nova imagem
docker run \
	--name jenkins-blueocean \
	--restart=on-failure \
	--detach \
	--network jenkins \
	--env DOCKER_HOST:tcp://docker:2376 \
	--env DOCKER_CERT_PATH=/certs/clients \
	--env DOCKER_TLS_VERIFY=1 \
	--publish 8080:8080 \
	--publish 50000:50000 \
	--volume jenkins-data:/var/jenkins_home \
	--volume jenkins-docker-certs:/certs/client:ro \
	meu-jenkins