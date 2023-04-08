#!/bin/bash
# Bash server that can be used by CI/CD pipelines to update self-hosted containers
# Requires a named pipe created by (and listened to) by the host in order to run commands on the host
# The named pipe will just transmit the names of the containers to update, implementation of update is up to the host
# Example implementation of the hostpipe is here https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-dock`er-container
# Link to example webserver in bash https://gist.github.com/leandronsp/3a81e488b792235b2be73f8def2f51e6

# This can be expanded to implement displaying metrics by running other commands on the host

# Deploy endpoint:
# PUT /deploy
# Body <container-name>
# Token $token (env variable)
# If valid token, send <container-name> to named pipe, send response "deployment triggered for <container-name>"
# Maybe: Set valid container names as env variables and send error response if body is invalid
# Maybe: Sanitize input (not sure how trivial that is. Not needed if above is implemented. Removing &&, ||, ;, etc would be a first step). 
# Maybe: Do neither of the above. Instead, just make this a messaging service that just sends to the host whatever it gets. Handle santization and parsing on the host.

# Testing out the named pipe
echo "here goes nothing..."
eval "$(cat /webserver/pipe)" &
echo "cat LICENSE" > /webserver/pipe