# Bash server that can be used by CI/CD pipelines to update self-hosted containers
# Requires a named pipe created by (and listened to) by the host in order to run commands on the host
# The named pipe will just transmit the names of the containers to update, implementation of update is up to the host
# Example implementation of the hostpipe is here https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-docker-container
# Link to example webserver in bash https://gist.github.com/leandronsp/3a81e488b792235b2be73f8def2f51e6

# This can be expanded to implement displaying metrics by running other commands on the host