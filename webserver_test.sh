#!/bin/bash
# Test suite for webserver
# Test pipe functionality

docker run --rm \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v "$(pwd)"/:/tmp/host \
   -e HOST_CWD="$(pwd)" \
   --entrypoint /tmp/host/webserver_test_pt_2.sh \
   docker
echo "Back on the host"