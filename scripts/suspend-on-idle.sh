#! /bin/bash

## CONFIG

SLEEP_THRESHOLD_MINUTES=60

## VARS

SESSION_START_IDLE_FILE="/tmp/$$-session-idle-start"

## SCRIPT

trap "echo 'Shutting down idle watcher'; exit 0" SIGTERM SIGINT

cached_pid=""
display=""
user_xauthority=""

while true; do

  pid=$(pgrep -x awesome | head -n1)

  if [ -z "$pid" ]; then
    # no graphical session started yet.
    # manually start timer for action

    current_time=$(date +%s%3N)

    if [ -f "$SESSION_START_IDLE_FILE" ]; then
      start_time=$(< "$SESSION_START_IDLE_FILE")
      idle_millis=$(($current_time - $start_time))
    else
      echo "No graphical session found. Starting new login timeout"
      echo $current_time > "$SESSION_START_IDLE_FILE"
      idle_millis=0
    fi
    cached_pid=""

  else

    if [ -f "$SESSION_START_IDLE_FILE" ]; then
      echo "Graphical session begun. Killing login timeout"
      rm "$SESSION_START_IDLE_FILE"
    fi

    if [ "$pid" != "$cached_pid" ]; then
      display=$(tr '\0' '\n' < "/proc/$pid/environ" | awk -F= '$1=="DISPLAY" {print $2}')
      user_xauthority=$(tr '\0' '\n' < "/proc/$pid/environ" | awk -F= '$1=="XAUTHORITY" {print $2}')

      if [ -z "$user_xauthority" ]; then
          graphical_user=$(stat -c '%U' "/proc/$pid")
          user_home=$(getent passwd "$graphical_user" | cut -d: -f6)
          user_xauthority="$user_home/.Xauthority"
      fi

      cached_pid="$pid"
    fi

    if ! idle_millis=$(DISPLAY=$display XAUTHORITY=$user_xauthority xprintidle 2>/dev/null); then
      echo "Failed to get idle millis from X session. DISPLAY was $display"
      sleep 60
      continue
    fi

  fi

  idle_minutes=$((idle_millis / 60000))

  if [[ $idle_minutes -ge $SLEEP_THRESHOLD_MINUTES ]]; then

    # check for systemd inhibitors
    if systemd-inhibit --list --mode=block --what=sleep --no-legend --no-pager | grep -q .; then
      echo "System is idle, but an active systemd inhibitor block was detected. Staying awake."
      sleep 60
      continue
    fi

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
