#!/usr/bin/env sh
if [ -z "$HEALTHCHECK_PING_URL" ]; then
    >&2 echo 'var HEALTHCHECK_PING_URL is not set'
    exit 15
fi

if [ -z "$COMPOSE_PROJECT_NAME" ]; then
    >&2 echo 'var COMPOSE_PROJECT_NAME is not set'
    exit 16
fi

HEALTHCHECK_TIMEOUT=${HEALTHCHECK_TIMEOUT:-60}
which curl > /dev/null ||  apk add --no-cache curl

echo $$ > healthcheck-ping.pid

NL=$'\n'

RUNNING=true
# handle signals to exit from loop
trap "RUNNING=false; echo Exiting..." INT
trap "RUNNING=false; echo Exiting..." TERM
trap "RUNNING=false; echo Exiting..." EXIT

FORMAT='{{.Label
"com.docker.compose.service"}}'

ITERATION=0
while $RUNNING; do
  echo "Sleep $HEALTHCHECK_TIMEOUT"
  sleep "$HEALTHCHECK_TIMEOUT"

  HEALTHY=$(docker ps --all -f "label=com.docker.compose.project=$COMPOSE_PROJECT_NAME" -f health=healthy --format "$FORMAT" 2>&1)
  HEALTHY_EXIT_CODE=$?

  UNHEALTHY=$(docker ps --all -f "label=com.docker.compose.project=$COMPOSE_PROJECT_NAME" -f health=unhealthy --format "$FORMAT" 2>&1)
  UNHEALTHY_EXIT_CODE=$?

  if [ $HEALTHY_EXIT_CODE -eq 0 ] && [ $UNHEALTHY_EXIT_CODE -eq 0 ] && [ -n "$HEALTHY" ] && [ -z "$UNHEALTHY" ]; then
    echo "Healthcheck success"
    curl --url "$HEALTHCHECK_PING_URL" --max-time 10 --retry 5 --retry-delay 5 --retry-max-time 60 --data-binary "$HEALTHY"
  else
    echo "Healthcheck error"
    curl --url "$HEALTHCHECK_PING_URL/fail" --max-time 10 --retry 5 --retry-delay 5 --retry-max-time 60 \
    --data-binary "${UNHEALTHY}${NL}${UNHEALTHY_EXIT_CODE}${NL}${HEALTHY_HEALTHY_EXIT_CODE}${NL}${HEALTHY}"
  fi
done
