#!/bin/bash
# files: mycommands.sh
#
# this example is rendered after https://github.com/RG72/telegram-bot-bash
# to show how you can customize bashbot by only editing mycommands.sh
# NOTE: this is not tested, simply copied from original source and reworked!
#
#### $$VERSION$$ v0.7-pre2-4-g8dcbc29
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034


# uncomment the following lines to overwrite info and help messages
#'

# returned messages

bashbot_info='This bot allows you to request status of your system.
To begin using the bot, try with the /help command.
'
bashbot_help='*Availiable commands*:
/s *sensors*
/ss *smbstatus*
/free *memory status*
/md *raid status*
/lvs *lvm status*
/lvsd *Datailed lvm status*
/df *disk space*
/ifconfig *ifconfig output*
/smart *-d sda* _smart status for sda drive_
'
IDMESSAGEPRE="Your chat identifier is"


# your additional bahsbot commands
# NOTE: command can have @botname attached, you must add * in case tests... 
mycommands() {
    if user_is_allowed "${USER[ID]}" "systemstatus"; then
	case "$MESSAGE" in
		'/md'|'raid_status') msg="$(cat /proc/mdstat)";;
		'/ss'|'smbstatus')
			msg=""
			smbstatus >/tmp/smbstatus
			send_doc "$TARGET" "/tmp/smbstatus"
			prevActiveTime=$curTime
			;;
		'/s'|'sensors'|'/sensors') msg="$(sensors | sed -r 's/\s|\)+//g' | sed -r 's/\(high=|\(min=/\//' | sed -r 's/\,crit=|\,max=/\//')";;
		'/free') msg="$(free -h)";;
		'/pvs') msg="$(pvs)";;
		'/ifconfig') msg="$(ifconfig)";;
		'/vgs') msg="$(vgs)";;
		'/lvs') msg="$(lvs | sed -r 's/\s+/\n/g')";;
		'/lvsd') msg="$(lvs -a -o +devices | sed -r 's/\s+/\n/g')";;
		'/smart'|'/smartctl')
			if [ "$OPTARG" == "" ]; then
				msg="example \`/smart sda\`"
				else
				drive="$(echo "$OPTARG" | cut -c 1-3)"
				echo "smartctl -a /dev/$drive"
				msg="$(smartctl -a "/dev/$drive")"
			fi
			;;
		'/df') msg="$(df -h | sed -r 's/^/\n/' | sed -r 's/\s+/\n/g')";;
	esac

	if [ "$msg" != "" ]; then
		send_telegram "${CHAT[ID]}" "$msg" 
	fi
    else
	send_normal_message "Sorry, you are not allowed to use this bot!"
    fi
}

# place your processing functions here

# converts newlines for telegram and send as one message
# $1 chat
# $2 message
send_telegram() {
	# output to telegram
	send_message "${1}" "$(sed <<< "${2}" -e ':a;N;$!ba;s/\n/ mynewlinestartshere /g')"
} # 2>>"$0.log"

