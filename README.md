# Linux-Cronjob-Scheduler
Heya! This repository is for my team (PID-08) linux project named 'Cronjob Scheduler'.


# cronjob-scheduler

A simple, terminal-based tool to manage your cron jobs with an easy-to-use menu. No need to remember crontab syntax or edit files manually — just run the script and follow the prompts.

## What it does

This script helps you:

- Add new cron jobs
- View your existing jobs
- Edit or update a job
- Delete a job
- Back up your current crontab
- Restore from a backup

Everything happens inside a clean, dialog-based interface right in your terminal.

## Why this exists

Working with `crontab -e` is fine if you’re comfortable with it. But for quick changes, backups, or even teaching others how cron works, it’s not ideal. This script removes that friction and gives you a more guided experience, without hiding how cron actually works.

## Getting started

Make sure you have `dialog` installed:

```bash
# Ubuntu/Debian
sudo apt install dialog

# macOS (with Homebrew)
brew install dialog
