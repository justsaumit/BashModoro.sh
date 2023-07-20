#!/bin/bash

# Dependency check
[ $(command -v notify-send) ] || {
	echo "Please install libnotify for notifications"
	exit 1
}

# Folder with subdirectories pre-work,post-work,post-break
# with custom sound files in the format Person-Quote.wav
soundfolder="$HOME/.local/share/voices"
# Change to s,m or h for- seconds,minutes and hours
default_time_unit=m

declare -A pomo_options
pomo_options["work"]="25"
pomo_options["break"]="5"

function show_usage() {
	echo "Usage: bashmodoro work|break [number of sets]"
	echo "Example: bashmodoro work 4"
}

function timer() {
	local bwhite='\033[1m'
	local borange='\e[1;38;5;202m'
	local bred='\e[1;38;5;196m'
	local nc='\033[0m'
	local first_arg_error_msg="Invalid input! Please provide a valid time in seconds, minutes (m), hours (h), or a combination (e.g., 2h30m)."
	# Function to convert time to seconds
	function convert_to_seconds() {
		local input=$1
		local time_mode=${input: -1}
		local value=${input::-1}
		if [[ $time_mode =~ ^[hms]$ ]]; then
			case $time_mode in
			"s") echo "$value" ;;
			"m") echo "$((value * 60))" ;;
			"h") echo "$((value * 3600))" ;;
			esac
		else
			time_mode="s" # Assign default time_mode 's'
			echo "$input" # Treat single number as seconds
		fi
	}
	# Check if arguments are provided
	if [[ $# -eq 0 || ! $1 =~ ^[0-9]+([hms])?$ ]]; then
		echo -e "$first_arg_error_msg"
		exit 1
	fi
	# Extract total_time and time_mode from the input arguments
	local total_time=$(convert_to_seconds "$1")
	# Assign time_mode
	if [[ $1 =~ [hms]$ ]]; then
		local time_mode=${1: -1}
		local value=${1::-1}
	else
		local value=$1
		local time_mode="s"
	fi
	# display timer settings
	echo -e "\n\n\tSession duration: ${bwhite}$value$time_mode${nc}\n\t"
	# starting timer message
	echo -e "\t${bwhite}Starting timer at $(date +"%r")"
	echo -e "\t\tTiming in ${bwhite}$value$time_mode${nc}...\n"
	# Timer function
	function countdown_timer() {
		local duration=$1
		local show_timer=false
		while [[ $duration -gt 0 ]]; do
			if [[ $duration -le 60 ]]; then
				show_timer=true
			fi
			sleep 1
			duration=$((duration - 1))
			if $show_timer; then
				echo -ne "\r\t\t${bwhite}Timer: $duration sec${nc}"
			fi
		done
		echo -e "\n\t\t${bwhite}Timer ended at $(date +"%r")${nc}\n"
	}
	countdown_timer $total_time
}

# Check if a valid option is provided
if [ -z "$1" ] || [ -z "${pomo_options[$1]}" ]; then
	show_usage
	exit 1
fi

val="$1"
reps=${2:-1} # if 2nd argument(repetitions) not provided by default it's 1

# Determine the starting session type
if [ "$1" == "work" ]; then
	sessions=("work" "break")
else
	sessions=("break" "work")
fi

# Run the timer and print a message when it's done
for ((i = 1; i <= reps; i++)); do
	for session in "${sessions[@]}"; do
		if [ "$session" == "work" ]; then
			# If first work-rep play pre-work sound
			if [ $i -eq 1 ]; then
				pre_work_sound=$(find "$soundfolder/pre-work" -type f | shuf -n 1) # Person-Quote.wav
				# check is pre_work_sound is set, if yes then executes else skip
				if [[ -n "$pre_work_sound" ]]; then
					title="${pre_work_sound##*/}"              # Extract filename without directory
					quote="${pre_work_sound##*-}"              # Extract the part after hypher
					notify-send "${title%%-*}" "${quote%.wav}" # Extract before hyphen, Remove .wav extension
					paplay "$pre_work_sound"
				fi
			fi
			# Assign post-work sound
			sound_file=$(find "$soundfolder/post-work" -type f | shuf -n 1) # Person-Quote.wav
		else
			# Else assign post-break sound
			if [ $i -ne $reps ]; then
				sound_file=$(find "$soundfolder/post-break" -type f | shuf -n 1) # Person-Quote.wav
			else
				unset sound_file
			fi
		fi
		# If lolcat is installed use it, if not run plain
		command -v lolcat >/dev/null 2>&1 && { echo "Pomodoro $i: $session" | lolcat; } || echo "Pomodoro $i: $session"
		timer "${pomo_options[$session]}""$default_time_unit"
		# check is sound_file is set, if yes then executes else skip
		if [[ -n "$sound_file" ]]; then
			# Play a sound when each timer ends
			sound_file_name="${sound_file##*/}"                                                       # Extract filename without directory
			notify-send "${sound_file_name%%-*}" "$(echo "${sound_file_name#*-}" | sed 's/\.wav$//')" # Person: Quote
			paplay "$sound_file"
		fi
	done
done
