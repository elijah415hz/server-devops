#!/bin/sh
cd /tmp/host
echo "making the pipe..."
mkfifo test-pipe
echo "listening to the pipe..."
eval "$(cat test-pipe)" &
echo "building the test container..."
docker build . -t "webserver"
echo "running the test container..."
docker run --rm -v "$HOST_CWD"/test-pipe:/webserver/pipe webserver
echo "Back on the container container..."
``