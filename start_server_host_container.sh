#!/bin/bash
# Test suite for webserver
# Test pipe functionality

docker build . -f testHost.Dockerfile -t testhost
docker network create --driver bridge test-network

docker run --rm \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v "$(pwd)"/:/tmp/host \
   -e HOST_CWD="$(pwd)" \
   --network=test-network \
   --name serverhost \
   testhost

if [ $? -ne 0 ]; then
   echo "Tests Failed"
fi

sleep 1
echo "Stopping server..."
docker kill webserver > /dev/null
