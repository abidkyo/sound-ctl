#!/usr/bin/env bash

# Author: Abid Sulaiman
# Title: Setup Script for Sound Control
# Description:
# Script to setup Sound Control Script
#   - Set default sink and sources.
#   - Set speaker and headphone port.

set -eo pipefail

id_sink=0
id_source=1
id_speaker=0
id_headphone=1

string_sink_source=("sink" "source")
string_speaker_headphone=("speaker" "headphone")

# Change argument separator
IFS=$'\n'

show_help() {
	cat <<EOF
Setup Script for Sound Control Script.
Usage: $(basename $0)

EOF
	exit 1
}

set_new_default() {
	local string=${string_sink_source[$1]}

	# Get list of sinks/sources.
	local list=($(pactl list short ${string}s | cut -f 1-2))
	local list_count=${#list[@]}

	# Select which sink/source to use as default sink/source.
	while true; do
		echo "Please select one of the ${string}s to be the default $string?"
		for item in ${list[@]}; do
			echo "$item"
		done
		echo -n "Your choice (0-$(($list_count - 1)))> "
		read REPLY

		local re='^[0-9]$'
		if ! [[ $REPLY =~ $re && $REPLY -lt $list_count ]]; then
			echo
			echo "Invalid choice"
		else
			local choice=$(echo ${list[$REPLY]} | cut -f 2)
			break
		fi
	done

	# Set default sink/source.
	echo "Setting default $string to $choice"
	pactl set-default-${string} $choice
	default_sink_source[$1]=$choice
}

ask_default() {
	local string=${string_sink_source[$1]}
	local default=${default_sink_source[$1]}

	while true; do
		echo "Would you like to use "$default" as the default $string?"
		echo -n "Your choice (y/N)> "
		read REPLY

		if ! [[ $REPLY =~ ^y|N$ ]]; then
			echo # blank line
			echo "Invalid choice"
		elif [[ $REPLY =~ ^N$ ]]; then
			echo # blank line
			set_new_default $1
			break
		else
			break
		fi
	done
	echo # blank line
}

assign_speaker_headphone() {
	# Check how many ports available for the default sink.
	local ports=($(
		pactl list sinks |
			sed -n "/Name: ${default_sink_source[$id_sink]}$/,/Active Port/{/Ports/,//p}" |
			sed -E '1d;$d;s/^\s+([a-z-]+):.*$/\1/'
	))
	local port_count=${#ports[@]}

	if [[ ${#ports[@]} -eq 0 ]]; then
		echo "This sink have no port. This must be some kind of error"
		exit 1
	elif [[ ${#ports[@]} -eq 1 ]]; then
		echo "This sink have only one (1) port. This program might not benefit you."
		exit 1
	fi

	# Assign speaker and headphone.
	for str in ${string_speaker_headphone[@]}; do
		while true; do
			echo "Which port should be set as $str port?"

			local ct=0
			for p in ${ports[@]}; do
				echo "$((ct++)) $p"
			done

			echo -n "Your choice (0-$(($port_count - 1)))> "
			read REPLY

			local re='^[0-9]$'
			if ! [[ $REPLY =~ $re && $REPLY -lt $port_count ]]; then
				echo
				echo "Invalid choice"
			else
				local choice=${ports[$REPLY]}
				echo "Setting $str to $choice"
				speaker_headphone+=($choice)
				break
			fi
		done
		echo # blank line
	done

}

# Check if argument given.
[[ -n $1 ]] && show_help

# Check if pactl command exist.
if ! which pactl >/dev/null; then
	echo "pactl is not installed"
	exit 1
fi

# Get default sink and source.
default_sink_source=($(pactl info | sed -nE -e '/Sink/,/Source/p'))
default_sink_source=("${default_sink_source[@]##*: }")

# Set default sink and source.
ask_default $id_sink
ask_default $id_source

# Assigned which one is speaker and headphone.
assign_speaker_headphone

echo "Default Sink: ${default_sink_source[$id_sink]}"
echo "Default Source: ${default_sink_source[$id_source]}"
echo # blank line

echo "Speaker Port: ${speaker_headphone[$id_speaker]}"
echo "Headphone Port: ${speaker_headphone[$id_headphone]}"
echo # blank line

# Replace config inside script.
sed -i -E "
s/^(outputSink=).*\$/\1\"${default_sink_source[$id_sink]}\"/;
s/^(inputSource=).*\$/\1\"${default_sink_source[$id_source]}\"/;
s/^(speakerPort=).*\$/\1\"${speaker_headphone[$id_speaker]}\"/;
s/^(headphonePort=).*\$/\1\"${speaker_headphone[$id_headphone]}\"/;
" ./sound-ctl.sh

exit 0
