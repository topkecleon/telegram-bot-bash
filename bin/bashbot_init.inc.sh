#!/bin/bash
#===============================================================================
#
#          FILE: bashbot_init.inc.sh
# 
#         USAGE: source bashbot_init.inc.sh
#
#   DESCRIPTION: extend / overwrite bashbot initialisation
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 27.01.2021 13:42
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================
# shellcheck disable=SC2059

##########
# commands to execute before bot_init() is called


########
# called after default init is finished
my_init() {
	: # your init here
}


#########
#
# extended initialisation:
#
# - uograde old config
# - backup of botconfig.jssh
# - running bot as service or other user
# - copy clean and dist files if not exist
# - configure bot for INLINE CALLBACK MEONLY SILENCER
# 
# delete from here to disable extended initialisation
bot_init() {
	if [ -n "${BASHBOT_HOME}" ] && ! cd "${BASHBOT_HOME}"; then
		 printf "Can't change to BASHBOT_HOME"
		 exit 1
	fi
	local runuser chown touser botname DEBUG="$1"
	# upgrade from old version
	# currently no action
	printf "Check for Update actions ...\n"
	printf "Done.\n"
	# load addons on startup
	printf "Initialize modules and addons ...\n"
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "init" "${DEBUG}"
	done
	printf "Done.\n"
	# guess bashbot from botconfig.jssh owner:group
	[ -f "${BOTCONFIG}.jssh" ] && runuser="$(stat -c '%U' "${BOTCONFIG}.jssh"):$(stat -c '%G' "${BOTCONFIG}.jssh")"
	# empty or ":" use user running init, nobody for root
	if [ "${#runuser}" -lt 3 ]; then
		# shellcheck disable=SC2153
		runuser="${RUNUSER}"
		[ "${UID}" = "0" ] && runuser="nobody"
	fi
	printf "Enter User to run bashbot [${runuser}]: "
	read -r chown
	[ -z "${chown}" ] && chown="${runuser}"
	touser="${chown%:*}"
	# check user ...
	if ! id "${touser}" &>/dev/null; then
		printf "${RED}User \"${touser}\" does not exist!${NN}"
		exit 3
	elif [ "${UID}" != "0" ]; then
		# different user but not root ...
		printf "${ORANGE}You are not root, adjusting permissions may fail. Try \"sudo ./bashbot.sh init\"${NN}Press <CTRL+C> to stop or <Enter> to continue..." 1>&2
		[ -n "${INTERACTIVE}" ] && read -r runuser
	fi
	# check if mycommands exist
	if [[ ! -r "${BASHBOT_ETC:-.}/mycommands.sh" && -r ${BASHBOT_ETC:-.}/mycommands.sh.dist ]]; then
		printf "Mycommands.sh not found, copy ${GREY}<C>lean file, <E>xamples or <N>one${NC} to mycommands.sh? (c/e/N) N\b"
		read -r ANSWER
		[[ "${ANSWER}" =~ ^[cC] ]] && cp -f "${BASHBOT_ETC:-.}/mycommands.sh.clean" "${BASHBOT_ETC:-.}/mycommands.sh"
		[[ "${ANSWER}" =~ ^[eE] ]] && cp -f "${BASHBOT_ETC:-.}/mycommands.sh.dist" "${BASHBOT_ETC:-.}/mycommands.sh"
		# offer to copy config also
		if [ ! -r "${BASHBOT_ETC:-.}/mycommands.conf" ]; then
			printf "Mycommands config file not found, copy ${GREY}mycommands.conf.dist${NC} to mycommands.conf? (Y/n) Y\b"
			read -r ANSWER
			[[ "${ANSWER}" =~ ^[nN] ]] || cp -f "${BASHBOT_ETC:-.}/mycommands.conf.dist" "${BASHBOT_ETC:-.}/mycommands.conf"
		fi
		# adjust INLINE CALLBACK MEONLY SILENCER
		if [ -w "${BASHBOT_ETC:-.}/mycommands.conf" ]; then
			printf "Activate processing for ${GREY}<I>nline queries, <C>allback buttons, <B>oth or <N>one${NC} in mycommands.sh? (i/c/b/N) N\b"
			read -r ANSWER
			[[ "${ANSWER}" =~ ^[iIbB] ]] && sed -i '/INLINE="/ s/^.*$/export INLINE="1"/' "${BASHBOT_ETC:-.}/mycommands.conf"
			[[ "${ANSWER}" =~ ^[cCbB] ]] && sed -i '/CALLBACK="/ s/^.*$/export CALLBACK="1"/' "${BASHBOT_ETC:-.}/mycommands.conf"
			printf "Always ignore commands for other Bots in chat ${GREY}(/cmd@other_bot)${NC}? (y/N) N\b"
			read -r ANSWER
			[[ "${ANSWER}" =~ ^[yY] ]] && sed -i '/MEONLY="/ s/^.*$/export MEONLY="1"/' "${BASHBOT_ETC:-.}/mycommands.conf"
			printf "Delete administrative messages in chats ${GREY}(pinned, user join/leave, ...)${NC}? (y/N) N\b"
			read -r ANSWER
			[[ "${ANSWER}" =~ ^[yY] ]] && sed -i '/SILENCER="/ s/^.*$/export SILENCER="yes"/' "${BASHBOT_ETC:-.}/mycommands.conf"
		fi
		printf "Done.\n"
	fi
	# adjust permissions
	printf "Adjusting files and permissions for user \"${touser}\" ...\n"
	chown -Rf "${chown}" . ./*
	chmod 711 .
	chmod -R o-w ./*
	chmod -R u+w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" logs "${LOGDIR}/"*.log 2>/dev/null
	chmod -R o-r,o-w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" "${BOTACL}" 2>/dev/null
	# jsshDB must writeable by owner
	find . -name '*.jssh*' -exec chmod u+w \{\} +
	printf "Done.\n"
	# adjust values in bashbot.rc
	if [ -w "bashbot.rc" ]; then
		printf "Adjust user and botname in bashbot.rc ...\n"
		sed -i '/^[# ]*runas=/ s|runas=.*$|runas="'"${touser}"'"|' "bashbot.rc"
		sed -i '/^[# ]*bashbotdir=/ s|bashbotdir=.*$|bashbotdir="'"${PWD}"'"|' "bashbot.rc"
		botname="$(getConfigKey "botname")"
		[ -n "${botname}" ] && sed -i '/^[# ]*name=/ s|name=.*$|name="'"${botname}"'"|' "bashbot.rc"
		printf "Done.\n"
	fi
	# ask to check bottoken online
	if [ -z "$(getConfigKey "botid")" ]; then
		printf "Seems to be your first init. Should I verify your bot token online? (y/N) N\b"
		read -r ANSWER
		if [[ "${ANSWER}" =~ ^[Yy] ]]; then
			printf "${GREEN}Contacting telegram to verify your bot token ...${NN}"
			$0 botname
		fi 
	fi
	# check if botconf seems valid
	printf "${GREEN}This is your bot config:${NN}${GREY}"
	sed 's/^/\t/' "${BOTCONFIG}.jssh" | grep -vF '["bot_config_key"]'; printf "${NC}"
	if check_token "$(getConfigKey "bottoken")" && [[ "$(getConfigKey "botadmin")" =~ ^[${o9o9o9}]+$ ]]; then
		printf "Bot config seems to be valid. Should I make a backup copy? (Y/n) Y\b"
		read -r ANSWER
		if [[ -z "${ANSWER}" || "${ANSWER}" =~ ^[^Nn] ]]; then
			printf "Copy bot config to ${BOTCONFIG}.jssh.ok ...\n"
			cp "${BOTCONFIG}.jssh" "${BOTCONFIG}.jssh.ok"
		fi 
	else
		printf "${ORANGE}Bot config may incomplete, pls check.${NN}"
	fi
	# show result
	printf  "${GREY}"; ls -ldp "${DATADIR}" "${LOGDIR}" ./*.jssh* ./*.sh ./*.conf 2>/dev/null; printf "${NC}"
	_exec_if_function my_init
}
