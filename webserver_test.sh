#!/bin/sh

function assert_equal() {
    if [ "${1}" == "${2}" ]; then
        echo "passed"
        return 0
    else
        echo "FAILED"
        echo "$1 is not equal to $2"
        return 1
    fi
}

cd /tmp/host
echo "making the pipe..."
mkfifo test-pipe

echo "building the server.."
docker build . -t "webserver"

echo "Running the server..."
docker run --rm \
    -v "$HOST_CWD"/test-pipe:/webserver/pipe \
    -p 8080:8080 \
    --network=test-network \
    webserver
    # TODO: This works when calling from the host, but not other containerss
sleep 2

echo "Running tests..."

echo "Sending a request to /deploy with a valid token will pass the service name to the pipe"

value=$( cat test-pipe ) &

curl -v -4 http://localhost:8080/ \
    # -H "Authorization: Bearer <ACCESS_TOKEN>" \
    # -H "Content-Type: application/json" \
    # -H '{"service":"myService"}'

assert_equal $value "myService"

echo "Back on the container container..."
