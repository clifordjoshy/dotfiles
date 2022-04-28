#!/bin/bash
# Default acpi script that takes an entry for all actions

runcmd() {
    command="$1"
    shift 1
    arg1="$1"
    shift 1
    body="$*"

    for pid in $(pgrep 'awesome'); do
        eval $(grep -z ^USER /proc/$pid/environ)
        eval export $(grep -z ^DISPLAY /proc/$pid/environ)
        eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
        res=$(su $USER -c "$command \"$arg1\" \"$body\"")
        echo $res
    done
}

case "$1" in
button/power)
    case "$2" in
    PBTN | PWRF)
        echo -n mem >/sys/power/state
        logger 'PowerButton pressed'
        ;;
    esac
    ;;
ac_adapter)
    case "$2" in
    ACPI0003:00)
        case "$4" in
        00000001)
            logger 'AC plugged'
            runcmd notify-send Power 'Charger plugged in'
            ;;
        esac
        ;;
    esac
    ;;
jack/headphone)
    case "$2" in
    HEADPHONE)
        case "$3" in
        unplug)
            runcmd playerctl pause
            ;;
        esac
        ;;

    esac
    ;;
video/brightnessup)
    light -A 10
    ;;
video/brightnessdown)
    light -U 10
    ;;
esac

# vim:set ts=4 sw=4 ft=sh et:
