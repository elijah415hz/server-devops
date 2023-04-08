FROM ubuntu
WORKDIR /webserver
COPY ./webserver.sh .
RUN chmod +x webserver.sh

ENTRYPOINT [ "./webserver.sh" ]