#!/bin/bash
# files: mycommands.sh
#
# this example is rendered after https://github.com/RG72/telegram-bot-bash
# to show how you can customize bashbot by only editing mycommands.sh
# NOTE: this is not tested, simply copied from original source and reworked!
#
#### $$VERSION$$ v1.52-1-g0dae2db
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034


# uncomment the following lines to overwrite info and help messages
#'

# returned messages

bashbot_info='This bot allows you to request status of your system.
To begin using the bot, try with the /help command.
'
bashbot_help='*Available commands*:
/se *sensors*
/smb *smbstatus*
/free *memory status*
/md *raid status*
/lvm *lvm status*
/lvsd *Datailed lvm status*
/df *disk space*
/ifconfig *ifconfig output*
/smart *-d sda* _smart status for sda drive_
'


# your additional bashbot commands
# NOTE: command can have @botname attached, you must add * in case tests... 
mycommands() {
    local msg=""

    if user_is_botadmin "${USER[ID]}" || user_is_allowed "${USER[ID]}" "systemstatus"; then
	case "${CMD}" in
		'/md'*) msg="$(cat /proc/mdstat)";;
		'/smb'*) msg="$(smbstatus)" ;;
		'/se'*) msg="$(sensors | sed -r 's/\s|\)+//g' | sed -r 's/\(high=|\(min=/\//' | sed -r 's/\,crit=|\,max=/\//')";;
		'/free'*) msg="$(free -h)";;
		'/pvs'*) msg="$(pvs)";;
		'/ifc'*) msg="$(ifconfig)";;
		'/vgs'*) msg="$(vgs)";;
		'/lvm'*) msg="$(lvs | sed -r 's/\s+/\n/g')";;
		'/lvsd'*) msg="$(lvs -a -o +devices | sed -r 's/\s+/\n/g')";;
		'/smart'*)
			[ "${CMD[1]}" == "" ] && msg="example \`/smart sda\`" && return
			drive="$(echo "${CMD[1]}" | cut -c 1-3)"
			echo "smartctl -a /dev/${drive}"
			msg="$(smartctl -a "/dev/${drive}")"
			;;
		'/df') msg="$(df -h | sed -r 's/^/\n/' | sed -r 's/\s+/\n/g')";;
	esac

	if [ "${msg}" != "" ]; then
		send_normal_message "${CHAT[ID]}" "${msg}" 
	fi
    else
	send_normal_message "${USER[ID]}" "Sorry, you are not allowed to use this bot!"
    fi
}

# place your processing functions here

