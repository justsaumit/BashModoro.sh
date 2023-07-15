#!/bin/bash

# Dependency check
[ $(command -v timer) ] || { echo "Please install timer"; exit 1; }
[ $(command -v lolcat) ] || { echo "Please install lolcat"; exit 1; }

# Folder with subdirectories pre-work,post-work,post-break
# with custom sound files in the format Person-Quote.wav
soundfolder="$HOME/.local/share/voices"

declare -A pomo_options
pomo_options["work"]="25"
pomo_options["break"]="5"

# Check if a valid option is provided
if [ -z "$1" ] || [ -z "${pomo_options[$1]}" ]; then
  echo "Please provide a valid option: work or break."
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
for (( i=1; i<=reps; i++ )); do
  for session in "${sessions[@]}"; do
    if [ "$session" == "work" ]; then
      # If first work-rep play pre-work sound
      if [ $i -eq 1 ]; then
        pre_work_sound=$(find "$soundfolder/pre-work" -type f | shuf -n 1) # Person-Quote.wav
        title="${pre_work_sound##*/}" # Extract filename without directory
        quote="${pre_work_sound##*-}" # Extract the part after hypher
        notify-send "${title%%-*}" "${quote%.wav}"  # Extract before hyphen, Remove .wav extension
        paplay "$pre_work_sound"
      fi
      # Assign post-work sound
      sound_file=$(find "$soundfolder/post-work" -type f | shuf -n 1)   # Person-Quote.wav
    else
      # Else assign post-break sound
      if [ $i -ne $reps ]; then
        sound_file=$(find "$soundfolder/post-break" -type f | shuf -n 1)  # Person-Quote.wav
      fi
    fi
    echo "Pomodoro $i: $session" | lolcat
    timer "${pomo_options[$session]}"m no_audio
    # Play a sound when each timer ends
    sound_file_name="${sound_file##*/}" # Extract filename without directory
    notify-send "${sound_file_name%%-*}" "$(echo "${sound_file_name#*-}" | sed 's/\.wav$//')"  # Person: Quote
    paplay "$sound_file"
  done
done
