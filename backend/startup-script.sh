#!/bin/bash
docker network create --driver bridge app-net;

docker run -d \
	--net app-net \
	--name paas-monitor \
	--env 'MESSAGE=gcp at ${region}' \
	--env RELEASE=v3.1.0 \
	--restart unless-stopped \
	mvanholsteijn/paas-monitor:3.1.0

docker run -d \
	--net app-net \
	-p 1337:8080 \
	--restart unless-stopped \
	gcr.io/endpoints-release/endpoints-runtime:1 \
		--service=${service_name} \
		--rollout_strategy=managed \
		--backend=paas-monitor:1337
