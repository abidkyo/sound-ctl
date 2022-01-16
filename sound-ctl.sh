#!/usr/bin/env bash

# Author: Abid Sulaiman
# Title: Sound Control
# Description:
# Script to control PulseAudio sound server.
#   - Get Input Status
#   - Toggle Input Status
#   - Get Output Status
#   - Toggle Output Status
#   - Get Volume Level
#   - Set Volume Level
#   - Get Sound Status
#   - Set Sound Default

set -eo pipefail

show_help() {
	cat <<EOF
Script to control PulseAudio sound server.
Usage: $(basename $0) OPTION [EXTRA_ARGS]

OPTION:
  gi  : get input status
  i   : toggle input status
  go  : get output status
  o   : toggle output status
  gv  : get volume level
  sv  : set volume level
  s   : get sound status
  d   : set sound default

EXTRA_ARGS is needed for OPTION:
  sv  : volume level between 0-100

EOF
	exit 1
}

# Use "pacmd list-sinks" to find your output sink and port names.
outputSink="alsa_output.pci-0000_0b_00.3.analog-stereo"
speaker="analog-output-lineout"
headphone="analog-output-headphones"

# Use "aplay -L" to find your input name.
inputSources="Snowball"

get_input() {
	if amixer -c "$inputSources" sget Mic | grep -o "\[on\]" >/dev/null; then
		echo "[on]"
	else
		echo "[off]"
	fi
}

toggle_input() {
	if [[ "$(get_input)" = "[on]" ]]; then
		echo "Toggle input off"
	else
		echo "Toggle input on"
	fi
	amixer -c "$inputSources" sset Mic toggle >/dev/null
}

get_output() {
	if pacmd list-sinks | grep 'active port' | grep lineout >/dev/null; then
		echo "SP"
	else
		echo "HP"
	fi
}

toggle_output() {
	if [[ "$(get_output)" = "SP" ]]; then
		echo "Toggle SP to HP"
		pacmd set-sink-port "$outputSink" "$headphone"
	else
		echo "Toggle HP to SP"
		pacmd set-sink-port "$outputSink" "$speaker"
	fi
}

get_volume() {
	if ! pacmd list-sinks | grep -A 10 "$outputSink" |
		grep -o 'volume: front-left:.*dB' | cut -d ' ' -f 6; then
		echo "Error getting volume"
	fi
}

set_volume() {
	if [[ $1 -ge 0 && $1 -le 100 ]]; then
		pactl set-sink-volume "$outputSink" $1%
		echo "Set volume to $1%"
	else
		echo "Invalid volume value"
	fi
}

get_status() {
	printf '{"input": "%s", "output": "%s", "volume": %s}\n' \
		"$(get_input)" "$(get_output)" "$(get_volume | tr -d "%")"
}

set_default() {
	# Set default volume for both ports.
	pacmd set-sink-port "$outputSink" "$headphone"
	pactl set-sink-volume "$outputSink" 50%
	pacmd set-sink-port "$outputSink" "$speaker"
	pactl set-sink-volume "$outputSink" 50%
}

case $1 in
"gi")
	get_input
	;;

"i")
	toggle_input
	;;

"go")
	get_output
	;;

"o")
	toggle_output
	;;

"gv")
	get_volume
	;;

"sv")
	set_volume $2
	;;

"s")
	get_status
	;;

"d")
	set_default
	;;

"-h" | "--help")
	show_help
	;;

*)
	echo "Invalid argument"
	show_help
	exit 1
	;;
esac

exit 0
