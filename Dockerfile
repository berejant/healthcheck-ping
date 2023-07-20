FROM --platform=${BUILDPLATFORM:-linux/amd64} docker
RUN  apk add --no-cache curl
ADD healthcheck-ping.sh /healthcheck-ping.sh

ENV COMPOSE_PROJECT_NAME ""
ENV HEALTHCHECK_TIMEOUT 60
ENV HEALTHCHECK_PING_URL ""

ENTRYPOINT /healthcheck-ping.sh

