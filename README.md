# Linux-Cronjob-Scheduler
Heya! This repository is for my team (PID-08) linux project named 'Cronjob Scheduler'.
FYI- cronscheduler.sh is the main file

#Team members
Anish - 2310991524
Asmi -2310991548
Ayush-2310991551
Gurleen-2310991579

# Cronjob-scheduler
A simple interactive tool to help you manage cron jobs on your Linux system.
This script allows you to view, add, delete, and backup your cron jobs using a terminal-based interface.

# Features
View your current crontab jobs

Add new cron jobs with easy input prompts

Delete existing jobs by selecting from a list

Backup your crontab to a file

Restore crontab from a saved backup

Fully interactive, keyboard-navigable menu

# Requirements
Bash (tested on bash 5+)

Unix-like OS (Linux or macOS)

dialog package (for the UI)

Install dialog if it's not already installed:

# Debian/Ubuntu
sudo apt-get install dialog

# macOS (with Homebrew)
brew install dialog

# Installation & Usage
Clone the repository and make the script executable:

cd cronjob-scheduler
chmod +x scheduler.sh
Run the script:

./scheduler.sh
Use the arrow keys and Enter to navigate the menu.

# A few things to note
This script only modifies your user-level crontab — it doesn’t touch system-wide jobs.

Backups are saved as cron_backup.txt in the same directory. You can change the filename or path in the script if needed.
