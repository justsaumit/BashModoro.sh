# BashModoro: Pomodoro with Quote Notifier

BashModoro is a minimalist and efficient time management tool for Linux, designed to help users enhance productivity and maintain focus during work sessions using the renowned Pomodoro Technique.  
Built upon the Unix philosophy of "Do one thing and do it well," the script leverages simple Unix commands, ensuring a minimalistic and effective approach to time management.  
It also notifies the users when Work session or Breaks are over via `notify-send` and `paplay`

## Features
**Sound Customization:** The script expects sound files to be organized in subdirectories within the soundfolder directory. Users can store custom sound files for pre-work, post-work, and post-break intervals, making the Pomodoro experience more personalized.

**Timer and Session Management:** The script uses the timer command to manage work and break sessions. Users can specify the number of repetitions for each session type. The script also handles the sequence of work and break sessions appropriately.

**Quote and Sound Notifications:** During the Pomodoro sessions, the script displays colored and stylized session information using lolcat, adding a touch of creativity to the experience. Additionally, it utilizes notify-send to display notifications with motivational quotes and reads them out custom quotes at the end of each session.
