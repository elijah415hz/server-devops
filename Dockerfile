FROM ubuntu
WORKDIR /webserver
RUN apt-get -y update && apt-get -y install netcat jq

COPY ./webserver.sh .
RUN chmod +x webserver.sh

ENTRYPOINT [ "./webserver.sh" ]