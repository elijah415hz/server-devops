#!/bin/sh

exitCode=0

function assert_equal_string() {
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

function assert_not_equal_int() {
    if [ $1 -ne $2 ]; then
        echo "********************"
        echo "PASSED"
        echo "********************"
        return 0
    else
        echo "!!!!!!!!!!!!!!!!!!!!"
        echo "FAILED"
        echo "!!!!!!!!!!!!!!!!!!!!"
        echo "$1 is equal to $2"
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

SECRET_TOKEN=SoSecret123
echo "Running the server..."
docker run --rm \
    -v "$HOST_CWD"/test-pipe:/webserver/pipe \
    -e SECRET_TOKEN=$SECRET_TOKEN \
    --network=test-network \
    --name webserver \
    webserver &
sleep 1

echo "Running tests..."

echo "======================================================================================"
echo "Sending a request to /message with a valid token will pass the service name to the pipe"
echo "======================================================================================"

body='{"message":"deploy-myService"}'

assert_equal_string $(cat test-pipe) "deploy-myService" &
ASSERT_EQUAL_PID=$!

curl -s -X POST webserver:8080/message \
    -H "Authorization: Bearer $SECRET_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Content-Length: $( echo -n $body | wc -c )" \
    -d $body \
    > /dev/null

wait $ASSERT_EQUAL_PID
TEST_STATUS_CODE=$?

if [ $TEST_STATUS_CODE -ne 0 ]; then
    exit $TEST_STATUS_CODE
fi

echo "=============================================="
echo "Sending a request with invalid token will fail"
echo "=============================================="

curl -s -X POST webserver:8080/message \
    -H "Authorization: Bearer badToken123" \
    -H "Content-Type: application/json" \
    -H "Content-Length: $( echo -n $body | wc -c )" \
    -d $body

assert_not_equal_int $? 0
if [ $? -ne 0 ]; then
    exit $?
fi
echo "=============================================="
echo "Sending a request with invalid route will fail"
echo "=============================================="

curl -s -X POST webserver:8080/notValid \
    -H "Authorization: Bearer $SECRET_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Content-Length: $( echo -n $body | wc -c )" \
    -d $body

assert_not_equal_int $? 0
if [ $? -ne 0 ]; then
    exit $?
fi