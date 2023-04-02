FROM ubuntu
COPY ./webserver.sh .

VOLUME /hostpipe

ENTRYPOINT [ "webserver.sh" ]