#! /bin/bash

## CONFIG

SLEEP_THRESHOLD_MINUTES=30

## VARS

SESSION_START_IDLE_FILE="/tmp/$$-session-idle-start"
GRAPHICAL_USER="cliford"

## SCRIPT

trap "echo 'Shutting down idle watcher'; exit 0" SIGTERM SIGINT

while true; do

  pid=$(pidof awesome || true)

  if [ -z "$pid" ]; then
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

    display=$(grep -z ^DISPLAY /proc/$pid/environ | cut -z -d'=' -f2 | tr -d '\0')
    idle_millis=$(DISPLAY=$display sudo -u $GRAPHICAL_USER xprintidle)

    if [ ! $? -eq 0 ]; then
      echo "Failed to get idle millis from X session. DISPLAY was $display"
      continue
    fi

  fi

  idle_minutes=$((idle_millis / 60000))

  if [[ $idle_minutes -ge $SLEEP_THRESHOLD_MINUTES ]]; then
		echo "Caught lacking. Time to sleep"

    charge_state=$(upower -i /org/freedesktop/UPower/devices/DisplayDevice | awk '/state/ {print $2}')

    if [[ "$charge_state" == "charging" || "$charge_state" == "pending-charge"  || "$charge_state" == "fully-charged" ]]; then
      systemctl suspend
    else
  		systemctl suspend-then-hibernate
    fi
  fi

  sleep 60
done
