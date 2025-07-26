#! /bin/bash

## CONFIG

SLEEP_THRESHOLD_MINUTES=30

## VARS

SESSION_START_IDLE_FILE="/tmp/$$-session-idle-start"
GRAPHICAL_USER="cliford"

while true; do

  pid=$(pidof awesome)

  if [ ! $? -eq 0 ]; then
    # no graphical session started yet.
    # manually start timer for action

    current_time=$(date +%s%3N)

    if [ -f $SESSION_START_IDLE_FILE ]; then
      start_time=$(< $SESSION_START_IDLE_FILE)
      idle_millis=$(($current_time - $start_time))
    else

      echo "No graphical session found. Starting new login timeout"

      echo $current_time > $SESSION_START_IDLE_FILE
      idle_millis=0
    fi

  else

    if [ -f $SESSION_START_IDLE_FILE ]; then
      echo "Graphical session begun. Killing login timeout"

      rm $SESSION_START_IDLE_FILE
    fi

    # get the DISPLAY envvar
    DISPLAY="$(grep -z ^DISPLAY /proc/$pid/environ | cut -z -d'=' -f2 | tr -d '\0' )"
    idle_millis=$(DISPLAY=$DISPLAY sudo -u $GRAPHICAL_USER xprintidle 2>/dev/null )

    if [ $? -eq 0 ]; then
      # successfully got idle time
      idle_minutes=$((idle_millis / 60000))
    else
      echo "Failed to get idle millis from X session. DISPLAY was $DISPLAY"
      continue
    fi

  fi

  if [[ $idle_minutes -eq $SLEEP_THRESHOLD_MINUTES ]]; then
    systemctl suspend-then-hibernate
  fi

  sleep 60

done