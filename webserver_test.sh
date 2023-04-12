#!/bin/sh

exitCode=0

function assert_equal() {
    if [ "${1}" == "${2}" ]; then
        echo "********************"
        echo "PASSED"
        echo "********************"
        return 0
    else
        echo "!!!!!!!!!!!!!!!!!!!!"
        echo "FAILED"
        echo "!!!!!!!!!!!!!!!!!!!!"
        echo "$1 is not equal to $2"
        return 1
    fi
}

# TODO: Just call webserver.sh, another docker container may not be necessary here. Having trouble with the actions...
# I think the only assumption then is that the named pipe works

cd /tmp/host
echo "making the pipe..."
mkfifo test-pipe

echo "building the server.."
docker build . -t "webserver"

echo "Running the server..."
docker run --rm \
    -v "$HOST_CWD"/test-pipe:/webserver/pipe \
    --network=test-network \
    --name webserver \
    webserver &
sleep 1

echo "Running tests..."

echo "Sending a request to /deploy with a valid token will pass the service name to the pipe"

body='{"service":"myService"}'

assert_equal $(cat test-pipe) myServie &
ASSERT_EQUAL_PID=$!

curl -s webserver:8080/deploy \
    -H "Authorization: Bearer <ACCESS_TOKEN>" \
    -H "Content-Type: application/json" \
    -H "Content-Length: $( echo -n $body | wc -c )" \
    -d $body \
    > /dev/null

wait $ASSERT_EQUAL_PID
testStatusCode=$?
exit $testStatusCode