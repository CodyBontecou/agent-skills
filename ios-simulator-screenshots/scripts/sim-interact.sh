#!/bin/bash
# Interact with the iOS Simulator via idb
# Usage: sim-interact.sh <action> [args...] [--udid <udid>]
#
# Actions:
#   tap <x> <y>                         Tap at device-point coordinates
#   swipe <x1> <y1> <x2> <y2>          Swipe between two points
#   text <string>                        Type text into focused field
#   button <HOME|LOCK|SIDE_BUTTON|SIRI>  Press a hardware button
#   key <keycode>                        Press a key
#   describe                             Get accessibility tree (JSON)
#   describe-point <x> <y>              Get accessibility info at a point
#   back                                 Swipe from left edge to go back (iOS nav gesture)
#   scroll-down                          Scroll down on the current screen
#   scroll-up                            Scroll up on the current screen
#   home                                 Press home button

set -euo pipefail

# Check idb is available
if ! command -v idb &> /dev/null; then
    echo "Error: idb (iOS Development Bridge) is not installed"
    echo "Install: pip install fb-idb"
    exit 1
fi

ACTION=""
ARGS=()
UDID_FLAG=""

# Parse arguments, extracting --udid
while [[ $# -gt 0 ]]; do
    case $1 in
        --udid) UDID_FLAG="--udid $2"; shift 2 ;;
        *)
            if [ -z "$ACTION" ]; then
                ACTION="$1"
            else
                ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    echo "Usage: sim-interact.sh <action> [args...] [--udid <udid>]"
    echo ""
    echo "Actions: tap, swipe, text, button, key, describe, describe-point, back, scroll-down, scroll-up, home"
    exit 1
fi

case "$ACTION" in
    tap)
        if [ ${#ARGS[@]} -lt 2 ]; then
            echo "Usage: sim-interact.sh tap <x> <y>"; exit 1
        fi
        idb ui tap ${ARGS[0]} ${ARGS[1]} $UDID_FLAG 2>/dev/null
        echo "✅ Tapped at (${ARGS[0]}, ${ARGS[1]})"
        ;;

    swipe)
        if [ ${#ARGS[@]} -lt 4 ]; then
            echo "Usage: sim-interact.sh swipe <x1> <y1> <x2> <y2>"; exit 1
        fi
        idb ui swipe ${ARGS[0]} ${ARGS[1]} ${ARGS[2]} ${ARGS[3]} --duration 0.3 $UDID_FLAG 2>/dev/null
        echo "✅ Swiped (${ARGS[0]},${ARGS[1]}) → (${ARGS[2]},${ARGS[3]})"
        ;;

    text)
        if [ ${#ARGS[@]} -lt 1 ]; then
            echo "Usage: sim-interact.sh text <string>"; exit 1
        fi
        idb ui text "${ARGS[0]}" $UDID_FLAG 2>/dev/null
        echo "✅ Typed: ${ARGS[0]}"
        ;;

    button)
        if [ ${#ARGS[@]} -lt 1 ]; then
            echo "Usage: sim-interact.sh button <HOME|LOCK|SIDE_BUTTON|SIRI>"; exit 1
        fi
        idb ui button "${ARGS[0]}" $UDID_FLAG 2>/dev/null
        echo "✅ Pressed button: ${ARGS[0]}"
        ;;

    key)
        if [ ${#ARGS[@]} -lt 1 ]; then
            echo "Usage: sim-interact.sh key <keycode>"; exit 1
        fi
        idb ui key "${ARGS[0]}" $UDID_FLAG 2>/dev/null
        echo "✅ Pressed key: ${ARGS[0]}"
        ;;

    describe)
        idb ui describe-all --json $UDID_FLAG 2>/dev/null
        ;;

    describe-point)
        if [ ${#ARGS[@]} -lt 2 ]; then
            echo "Usage: sim-interact.sh describe-point <x> <y>"; exit 1
        fi
        idb ui describe-point ${ARGS[0]} ${ARGS[1]} --json $UDID_FLAG 2>/dev/null
        ;;

    back)
        # iOS back gesture: swipe from left edge to right
        idb ui swipe 5 400 300 400 --duration 0.3 $UDID_FLAG 2>/dev/null
        echo "✅ Back gesture (left-edge swipe)"
        ;;

    scroll-down)
        idb ui swipe 200 600 200 300 --duration 0.3 $UDID_FLAG 2>/dev/null
        echo "✅ Scrolled down"
        ;;

    scroll-up)
        idb ui swipe 200 300 200 600 --duration 0.3 $UDID_FLAG 2>/dev/null
        echo "✅ Scrolled up"
        ;;

    home)
        idb ui button HOME $UDID_FLAG 2>/dev/null
        echo "✅ Home button pressed"
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo "Valid actions: tap, swipe, text, button, key, describe, describe-point, back, scroll-down, scroll-up, home"
        exit 1
        ;;
esac
