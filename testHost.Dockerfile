FROM docker

RUN apk update && apk add curl

ENTRYPOINT [ "/tmp/host/webserver_test.sh" ]