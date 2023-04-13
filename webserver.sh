#!/bin/bash
# Bash server that can be used by CI/CD pipelines to update self-hosted containers
# Requires a named pipe created by (and listened to) by the host in order to run commands on the host
# The named pipe will just transmit the names of the containers to update, implementation of update is up to the host
# Example implementation of the hostpipe is here https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-dock`er-container
# Link to example webserver in bash https://gist.github.com/leandronsp/3a81e488b792235b2be73f8def2f51e6

# This can be expanded to implement displaying metrics by running other commands on the host
echo "Starting up..."

rm -f response
mkfifo response

function handle_deploy() {
    echo $SERVICE_NAME > /webserver/pipe
    echo -n "HTTP/1.1 200 OK\r\n" > response
}

function handle_not_found() {
    echo -n "HTTP/1.1 404 OK\r\n" > response
}

function handleRequest() {
    while read line; do
        echo $line
        trline=$(echo $line | tr -d '[\r\n]') ## Removes the \r\n from the EOL

        ## Breaks the loop when line is empty
        [ -z "$trline" ] && break

        ## Parses the headline
        ## e.g GET /login HTTP/1.1 -> GET /login
        HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'
        [[ "$trline" =~ $HEADLINE_REGEX ]] &&
            REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")

        ## Parses the Content-Length header
        ## e.g Content-Length: 42 -> 42
        CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
        [[ "$trline" =~ $CONTENT_LENGTH_REGEX ]] &&
            CONTENT_LENGTH=$(echo $trline | sed -E "s/$CONTENT_LENGTH_REGEX/\1/")

        ## Parses the Cookie header
        ## e.g Cookie: name=John -> name John
        TOKEN_REGEX='Authorization:\sBearer\s(.*?)'
        [[ "$trline" =~ $TOKEN_REGEX ]] &&
            TOKEN=$(echo $trline | sed -E "s/$TOKEN_REGEX/\1/")
    done

      ## Read the remaining HTTP request body
    if [ ! -z "$CONTENT_LENGTH" ]; then
        while read -n$CONTENT_LENGTH -t1 line; do
            trline=`echo $line | tr -d '[\r\n]'`

            [ -z "$trline" ] && break

            SERVICE_NAME=$( echo $trline | jq '.service' | tr -d '"' )
        done
    fi

    echo "=========== HEADERS =============="
    echo "$REQUEST $CONTENT_LENGTH $TOKEN"

    if [ $SECRET_TOKEN != $TOKEN ]; then
        echo -n "HTTP/1.1 401 Unauthorized\r\nUnauthorized\r\n" > response
        return
    fi

    case "$REQUEST" in
        "PUT /deploy")   handle_deploy ;; 
        *)               handle_not_found ;; 
    esac
}

while true; do
  ## 1. wait for FIFO
  ## 2. creates a socket and listens to the port 3000
  ## 3. as soon as a request message arrives to the socket, pipes it to the handleRequest function
  ## 4. the handleRequest function processes the request message and routes it to the response handler, which writes to the FIFO
  ## 5. as soon as the FIFO receives a message, it's sent to the socket
  ## 6. closes the connection (`-N`), closes the socket and repeat the loop
  cat response | nc -lN 8080 | handleRequest
done