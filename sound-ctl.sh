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

# See setup script to see how these variables are set.
outputSink="alsa_output.pci-0000_0b_00.3.analog-stereo"
inputSource="alsa_input.usb-BLUE_MICROPHONE_Blue_Snowball_201306-00.mono-fallback"
speakerPort="analog-output-lineout"
headphonePort="analog-output-headphones"

get_input() {
	local mute=$(pactl list sources | grep -A 7 "Name: ${inputSource}$" | grep "Mute")
	if [[ "$mute" =~ "yes" ]]; then
		echo "[off]"
	elif [[ "$mute" =~ "no" ]]; then
		echo "[on]"
	else
		echo "Error getting input status"
		exit 1
	fi
}

toggle_input() {
	local status=$(get_input)
	if [[ "$status" = "[on]" ]]; then
		echo "Toggle input off"
	elif [[ "$status" = "[off]" ]]; then
		echo "Toggle input on"
	else
		echo "$status"
		echo "Error toggling input"
		exit 1
	fi
	pactl set-source-mute "$inputSource" "toggle"
}

get_output() {
	local active_port=$(pactl list sinks | grep -A 50 "Name: ${outputSink}$" | grep "Active Port")

	if [[ -z "$active_port" ]]; then
		echo "Error getting output status"
		exit 1
	fi

	if [[ "$active_port" =~ "$speakerPort" ]]; then
		echo "SP"
	elif [[ "$active_port" =~ "$headphonePort" ]]; then
		echo "HP"
	else
		echo "Error getting output status"
		exit 1
	fi
}

toggle_output() {
	local status=$(get_output)
	if [[ "$status" = "SP" ]]; then
		echo "Toggle SP to HP"
		pactl set-sink-port "$outputSink" "$headphonePort"
	elif [[ "$status" = "HP" ]]; then
		echo "Toggle HP to SP"
		pactl set-sink-port "$outputSink" "$speakerPort"
	else
		echo "$status"
		echo "Error toggling output"
		exit 1
	fi
}

get_volume() {
	if ! pactl list sinks | grep -A 10 "Name: ${outputSink}$" |
		grep -o "Volume: front-left:.*dB" | tr -s " " | cut -d ' ' -f 5; then
		echo "Error getting volume"
		exit 1
	fi
}

set_volume() {
	local volume=$1
	# Check if volume value is given.
	if [[ -z $volume ]]; then
		echo "No volume value given"
		show_help
	fi

	# Check if volume value between 0 and 100.
	if [[ ! $volume -ge 0 || ! $volume -le 100 ]]; then
		echo "Invalid volume value"
		show_help
	fi

	echo "Set volume to $volume%"
	pactl set-sink-volume "$outputSink" $volume%
}

get_status() {
	printf '{"input": "%s", "output": "%s", "volume": %s}\n' \
		"$(get_input)" "$(get_output)" "$(get_volume | tr -d "%")"
}

set_default() {
	# Set default volume for both ports.
	pactl set-sink-port "$outputSink" "$headphonePort"
	pactl set-sink-volume "$outputSink" 50%
	pactl set-sink-port "$outputSink" "$speakerPort"
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
	;;
esac

exit 0
