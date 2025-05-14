#!/bin/bash

# Comments and notes written by Asmi.
# If anyone from the team wants to change or fix something, just ping me directly.

# grabbing the current script directory (where this file is running from)
DIR="$(cd "$(dirname "$0")" && pwd)"

# where I’ll log stuff like added/deleted jobs
LOG="$DIR/cron_manager.log"

# temp file to hold cron jobs before saving or editing
TMP="$DIR/temp_cron.txt"

# backup file — just in case someone deletes stuff by mistake
BAK="$DIR/cron_backup.bak"

# make sure the log file exists
touch "$LOG"

# checking if 'dialog' is installed — without it nothing will show up properly
command -v dialog >/dev/null 2>&1 || { echo "You need to install 'dialog' for this to work."; exit 1; }

add_job() {
    # show calendar to pick a date
    dialog --calendar "Pick a date" 0 0 1 1 2025 2>"$DIR/date.tmp" || return
    DATE=$(cat "$DIR/date.tmp")
    rm "$DIR/date.tmp"

    # breaking date into pieces — year, month, day
    Y=$(echo "$DATE" | awk -F'/' '{print $3}')
    M=$(echo "$DATE" | awk -F'/' '{print $1}')
    D=$(echo "$DATE" | awk -F'/' '{print $2}')

    # ask user to enter hour and minute
    dialog --inputbox "Hour (0-23):" 8 40 2>"$DIR/hr.tmp" || return
    dialog --inputbox "Minute (0-59):" 8 40 2>"$DIR/min.tmp" || return

    # now ask for the command they want to run
    dialog --inputbox "Command to run:" 8 60 2>"$DIR/cmd.tmp" || return

    # grabbing input values from temp files
    H=$(cat "$DIR/hr.tmp")
    MIN=$(cat "$DIR/min.tmp")
    CMD=$(cat "$DIR/cmd.tmp")

    # delete the temp files after use
    rm "$DIR/hr.tmp" "$DIR/min.tmp" "$DIR/cmd.tmp"

    # putting the job in cron format
    ENTRY="$MIN $H $D $M * $CMD"

    # adding the job to the current crontab
    (crontab -l 2>/dev/null; echo "$ENTRY") | crontab -

    # logging that job was added
    echo "$(date): Added $ENTRY" >> "$LOG"
    dialog --msgbox "Job added!" 6 30
}
    
view_jobs() {
    # show current cron jobs in a textbox
    crontab -l > "$TMP" 2>/dev/null
    dialog --textbox "$TMP" 20 70
    echo "$(date): Viewed jobs" >> "$LOG"
}
    
backup_jobs() {
    # save current crontab to backup file
    crontab -l > "$BAK" 2>/dev/null
    echo "$(date): Backup saved" >> "$LOG"
}

delete_job() {
    crontab -l > "$TMP" 2>/dev/null || {
        dialog --msgbox "No crontab found." 6 40
        return
    }

    TOTAL=$(wc -l < "$TMP")
    if [ "$TOTAL" -eq 0 ]; then
        dialog --msgbox "No jobs to delete." 6 40
        return
    fi

    backup_jobs

    # Create a numbered view of crontab lines
    nl -w2 -s'. ' "$TMP" > "$DIR/numbered_cron.txt"

    dialog --textbox "$DIR/numbered_cron.txt" 20 70

    dialog --inputbox "Enter line number to delete (1-$TOTAL):" 8 50 2>"$DIR/del.tmp" || return
    L=$(cat "$DIR/del.tmp")
    rm "$DIR/del.tmp"

    if ! [[ "$L" =~ ^[0-9]+$ ]] || [ "$L" -lt 1 ] || [ "$L" -gt "$TOTAL" ]; then
        dialog --msgbox "Invalid line number!" 6 40
        return
    fi

    # Remove that line from original TMP file
    sed "${L}d" "$TMP" > "$DIR/updated_cron.txt"

    if crontab "$DIR/updated_cron.txt"; then
        echo "$(date): Deleted job line $L" >> "$LOG"
        dialog --msgbox "Job deleted successfully!" 6 40
    else
        dialog --msgbox "Failed to update crontab." 6 40
    fi
}

update_job() {
    # same as delete, but we add a new one after deleting the old one
    crontab -l > "$TMP" 2>/dev/null || { dialog --msgbox "No jobs to update." 6 30; return; }
    backup_jobs

    nl -ba "$TMP" > "$DIR/numbered.txt"
    dialog --textbox "$DIR/numbered.txt" 20 70

    dialog --inputbox "Line to update:" 8 40 2>"$DIR/line.tmp" || return
    L=$(cat "$DIR/line.tmp")
    rm "$DIR/line.tmp"

    sed -i "${L}d" "$TMP"
    crontab "$TMP"

    dialog --msgbox "Now enter new job details..." 6 30
    add_job
    
    echo "$(date): Updated line $L" >> "$LOG"
}

restore_backup() {
    # if there's a backup, use it — else show msg
    [ -f "$BAK" ] && crontab "$BAK" && dialog --msgbox "Backup restored!" 6 30 || dialog --msgbox "No backup found." 6 30
    echo "$(date): Restored backup" >> "$LOG"
}
    
show_help() {
    cat <<EOF > "$DIR/help.txt"
CRON JOBS FORMAT

Format is:
* * * * * command
| | | | |
| | | | +-- Day of week (0-7)
| | | +---- Month (1-12)
| | +------ Day (1-31)
| +-------- Hour (0-23)
+---------- Minute (0-59)

Examples:
0 17 * * * /home/user/myscript.sh
0 8 * * 1 /home/user/weekly.sh

Log file: $LOG
EOF
    dialog --textbox "$DIR/help.txt" 20 60
}
 
while true; do
    CHOICE=$(dialog --clear --backtitle "Cron Manager" --title "Menu" --menu "Choose what to do:" 15 40 7 \
        1 "Add Job" \
        2 "View Jobs" \
        3 "Update Job" \
        4 "Delete Job" \
        5 "Restore Backup" \
        6 "Exit" \
        7 "Help" \
        3>&1 1>&2 2>&3)
    
    case $CHOICE in
        1) add_job ;;
        2) view_jobs ;;
        3) update_job ;;
        4) delete_job ;;
        5) restore_backup ;;
        6) clear; echo "धन्यवद!"; exit ;;
        7) show_help ;;
        *) dialog --msgbox "eh? invalid choice" 6 30 ;;
    esac
done
