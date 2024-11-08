#!/usr/bin/env bash

####################################
### Options you should configure ###
####################################

TMUX="/path/to/tmux" # "/usr/bin/tmux"
TMUX_SESSION="minecraft" # "servers"
TMUX_WINDOW="server-console" # "server-1" To run multiple servers at the same time choose a unique TMUX_WINDOW for each.
JAVA="/path/to/java" # "/usr/lib/jvm/java-21-openjdk-arm64/bin/java"
SERVER_JAR="server.jar" # "fabric-server-mc.1.21.1-loader.0.16.9-launcher.1.0.1.jar"
RAM="4G" # "12G"

##############################
### DO NOT EDIT BELOW HERE ###
##############################

# Navigate into the directory the script is in (assumed to be the directory of the server)
# CAN BREAK IF cd IS USED BEFORE IT RUNS
cd "$(dirname "$0")"

SCRIPT_NAME="$(basename "$0")"
TMUX_PANE="${TMUX_SESSION}:${TMUX_WINDOW}.0"

# Fix tmux if started outside a shell (e.g. by systemd)
if [[ -n ${INVOCATION_ID+x} ]]; then
  TMUX="${TMUX} -C"
fi

# Determine the status of the server based on if the TMUX_PANE exists
STATUS="STOPPED"
if tmux has-session -t "${TMUX_PANE}" &> /dev/null; then
  STATUS="RUNNING"
fi

function printStatus() {
  echo "Current status of the server: ${STATUS}"
}

function startServer() {
  if [ "${STATUS}" = "RUNNING" ]; then
    echo "Server is already running"
    exit 1
  fi
  ## Start the server using tmux
  # tmux is used to make the server console available even if run as a systemd service
  # and to avoid closing the server when the ssh session ends.
  eval ${TMUX} start-server \\\; new-session -s "${TMUX_SESSION}" -n "${TMUX_WINDOW}" "${JAVA} -Xms${RAM} -Xmx${RAM} -jar '${SERVER_JAR}' nogui"
}

function stopServer {
  if [ "${STATUS}" = "STOPPED" ]; then
    echo "Server is already stopped"
    exit 1
  fi
  ## Stop the server by sending Ctrl+C to it
  # This has the same result as using stop but doesn't require the commandline to be empty.
  tmux send-keys -t "${TMUX_PANE}" C-c
}

function attachToTmuxPane() {
  tmux attach-session -t "${TMUX_PANE}"
}

case "$1" in
  status)
    printStatus;;
  start)
    startServer;;
  stop)
    stopServer;;
  console|con)
    attachToTmuxPane;;
  *)
    printStatus
    echo
    echo "Usage:"
    echo "  ${SCRIPT_NAME} status"
    echo "  ${SCRIPT_NAME} start"
    echo "  ${SCRIPT_NAME} stop"
    echo "  ${SCRIPT_NAME} console"
    exit 1;;
esac
