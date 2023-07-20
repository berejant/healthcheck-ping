### Run inside docker
```shell
docker run --privileged -it --rm \
  -v `pwd`:/src/ \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e COMPOSE_PROJECT_NAME=pigeon-app \
  -e HEALTHCHECK_PING_URL=https://hc-ping.com/cd205764-3489-43d2-9d26-41441830f67d \
  -e TIMEOUT=10 \
  --entrypoint /src/healthcheck-ping.sh \
  docker
```


### Run at host machine
```shell
COMPOSE_PROJECT_NAME=pigeon-app \
HEALTHCHECK_PING_URL=https://hc-ping.com/cd205764-3489-43d2-9d26-41441830f67d \
TIMEOUT=10 .\
/healthcheck-ping.sh
```

### Docker compose example
```yaml
services:
  healthcheck-ping:
    image: ghcr.io/kneu-messenger-pigeon/healthcheck-ping:latest
    restart: unless-stopped
    privileged: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - COMPOSE_PROJECT_NAME
      - HEALTHCHECK_PING_URL=https://hc-ping.com/cd205764-3489-43d2-9d26-41441830f67d
      - TIMEOUT=90
```
