#!/bin/bash
#===============================================================================
#
#          FILE: mycommands.sh
# 
#         USAGE: will be included from commands.sh 
# 
#   DESCRIPTION: real world example with jsshDB and send_keyboard
# 
#        AUTHOR: KayM (), kay@rrr.de
#          DATE: 19.12.2020 19:03
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================
# shellcheck disable=SC2154
# shellcheck disable=SC2034

bashbot_title='*Hallo, ich bin der @'"${ME//_/\\_}"'. Ich suche und finde Dealz!*'

bashbot_shelp="${bashbot_title}"'

Schicke mir https://t.me/'"${ME//_/\\_}"' einen Befehl mit *max. 50 Begriffen*. Ein Begriff muss mindesten 4 Zeichen lang sein.

*Befehle zum Suchen / Tracken  von Dealz:*
  /search  /suche _Suche in Deals der letzen 48h,
  z.B.:_ /suche   Apple  mavic.\*air

  /newtrack   _Tracking mit neuen Begriffen,
  z.B.:_ /newtrack    Apple  mavic.\*air
  /track /addkey   _zusätzlicher Begriff zum Tracken_
  /delkey       _lösche Begriff_

  /listtrack   _zeigt aktuell getrackte Begriffe_
  /delkey ALL  _löscht alle Begriffe_ 
  /stattrack   _Infos zum aktiven Tracking_

'

bashbot_commands='*Meine Befehle*:
  /info      _- Info zum Bot_
  /suche     _- Suchen und Tracken von Dealz_
  /hilfe    _- Hilfe zu weiteren Befehlen_

Du hast eine eigene Telegram Dealgruppe? Lade mich ein und alle in der Guppe können mich nutzen:
'

# uncomment the following lines to overwrite info and help messages
bashbot_info="${bashbot_title}"'

*Du willst Dealz suchen oder tracken?*
Klicke hier https://t.me/'"${ME//_/\\_}"' und schicke /start

'"${bashbot_commands}"'

*Dein '"${ME//_/-}"'*
'

bashbot_help="${bashbot_title}"'

*Du willst mich weiterempfehlen?*
Schicke https://t.me/'"${ME//_/\\_}"' an deinen Telegram Kontakt und sage ihm er soll darauf klicken und /start schicken.

'"${bashbot_commands}"'

*Dein '"${ME//_/-}"'*
'

# in a regular message is no need to escape '_'
SORRYADMIN="Du bist kein Gruppenadmin, diesen Befehl kannst Du nur im privaten Chat ausführen @${ME} <<- hier klicken"

# Set INLINE to 1 in order to receive inline queries.
# To enable this option in your bot, send the /setinline command to @BotFather.
INLINE="0"

# if your bot is group admin it get commands sent to other bots
# Set MEONLY to 1 to ignore commands sent to other bots
export MEONLY="1"

# Set to .* to allow sending files from all locations
FILE_REGEX='/this_is_my_bot_path/.*'
# run curl over TOR or SOCKS
#export BASHBOT_CURL_ARGS="--socks5-hostname localhost"

# unset BASHBOT_RETRY to enable retry in case of recoverable errors, e.g.  throtteling
# see logs/ERROR.log for information why send_messages etc. fail
unset BOTSEND_RETRY

# set value for adaptive sleeping while waitingnfor uodates in millisconds
# max slepp between polling updates 10s (default 5s)
export BASHBOT_SLEEP="10000"
# add 0.2s if no update available, up to BASHBOT_SLEEP (default 0.1s)
export BASHBOT_SLEEP_STEP="400"

# uncomment if you use keyboards in your commands
# export REMOVEKEYBOARD="yes"
export REMOVEKEYBOARD_PRIVATE="yes"

# uncomment if you want to say welcome to new chat members
export WELCOME_NEWMEMBER="yes"
WELCOME_MSG="Willkommen"

# uncomment if you want to be informed about new/left chat members
export REPORT_NEWMEMBER="yes"
export REPORT_LEFTMEMBER="yes"

# location of Database files
TRACKFILE="${DATADIR}/0-dealtrack"
SEARCHFILE="${DATADIR}/0-dealsearch"
WATCHFILE="${DATADIR}/0-dealwatch"

if [ "$1" = "startbot" ];then
    # mark startup, triggers action on first message
    setConfigKey "startupaction" "await"
    # create Database files on startup
    jssh_newDB "${TRACKFILE}"
    jssh_newDB "${SEARCHFILE}"
    jssh_newDB "${WATCHFILE}"
else

    # your additional bahsbot commands
    # NOTE: command can have @botname attached, you must add * in case tests... 
    mycommands() {
	# action triggered on first message after startup
	if [[ "$(getConfigKey "startupaction")" != "done"* ]]; then
		setConfigKey "startupaction" "done $(date)"
   	fi
	# a service Message was received
	local SILENCER="yes"
	if [[ "${SERVICE}" != "" ]]; then
		# example: dleted service messages
		if [ "${SILENCER}" = "yes" ] && bot_is_admin "${CHAT[ID]}"; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# remove keyboard if you use keyboards
	[ -n "${REMOVEKEYBOARD}" ] && remove_keyboard "${CHAT[ID]}" "..." &
	[[ -n "${REMOVEKEYBOARD_PRIVATE}" &&  "${CHAT[ID]}" == "${USER[ID]}" ]] && remove_keyboard "${CHAT[ID]}" "..." &

	# fix upper case first letter in commands
	[[ "${MESSAGE}" =~  ^/[[:upper:]] ]] && MESSAGE="${MESSAGE:0:1}$(tr '[:upper:]' '[:lower:]' <<<"${MESSAGE:1:1}")${MESSAGE:2}"

	######################
	# default commands
	case "${MESSAGE}" in
		'/info'*)
			send_action "${CHAT[ID]}" "typing"
			delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			send_markdownv2_message "${CHAT[ID]}" "${bashbot_info}"
			return 1 # continue with default action
			;;
		'/hel'*|'/hil'*)
			send_action "${CHAT[ID]}" "typing"
			delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			send_markdownv2_message "${CHAT[ID]}" "${bashbot_help}"
			return 1 # break, do not continue
			;;
		'/start'*)
			send_markdownv2_message "${CHAT[ID]}" "${bashbot_help}"
			return 1 # break, do not continue
			;;
		'/_edited_message'*)
			#return 1 # no
			# but if we do, remove /edited_message
			MESSAGE="${MESSAGE#/* }"
			;;
		'/_new_chat_member'*)
			if [[ -n "${WELCOME_NEWMEMBER}" && "${NEWMEMBER[ISBOT]}" != "true" ]] && bot_is_admin "${CHAT[ID]}"; then
			    send_normal_message "${CHAT[ID]}"\
				"${WELCOME_MSG} ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			fi
			[ -n "${REPORT_NEWMEMBER}" ] && send_normal_message "$(getConfigKey "botadmin")"\
			    "New member: ${CHAT[TITLE]} (${CHAT[ID]}): ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			;;
		'/_left_chat_member'*)
			[ -n "${REPORT_LEFTMEMBER}" ] && send_normal_message "$(getConfigKey "botadmin")"\
			    "Left member: ${CHAT[TITLE]} (${CHAT[ID]}): ${LEFTMEMBER[FIRST_NAME]} ${LEFTMEMBER[LAST_NAME]} (@${LEFTMEMBER[USERNAME]})"
			;;
	esac

	##########
	# pre test for admin only commands
	case "${MESSAGE}" in
		# must be private, group admin, or botadmin
		'/sea'*|'/su'*|'/add'*|'/new'*|'/del'*|'/tra'*)
			send_action "${CHAT[ID]}" "typing"
			if ! user_is_admin "${CHAT[ID]}" "${USER[ID]}" ; then
			    delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			    send_normal_message "${CHAT[ID]}" "${SORRYADMIN}"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			    return 1
			fi
			# ok, now lets process the real command 
			;;
	esac

	#################
	# search commands
	#local vairable, e.g. read/write Database
	local FINDKEYS OLDKEYS KEY MYSENTID
	declare -a KEYARR
 	declare -A SEARCHVALUES

	#################
	# pre processing of search commands
	case "${MESSAGE}" in
		'/add'*|'/tra'*) # add no arg
			FINDKEYS="${MESSAGE#/* }"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    send_normal_message "${CHAT[ID]}" "Kein Begriff angegeben!"
			    exit
			fi
			;;&
		'/add'[kbt]*|'/tra'*) OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			;;&
		'/addk'*|'/addt'*|'/tra'*) # add track
			MESSAGE="/newtrack ${FINDKEYS} ${OLDKEYS}"
			;;
		'/delk'*) #delete key
			OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			if [ "${OLDKEYS}" = "" ]; then
			    send_markdownv2_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"
			    return
			fi
			KEY="${OLDKEYS%%|!*}"
			FINDKEYS="${MESSAGE#/* }"
			read -r -a KEYARR <<<"ALL ${KEY//|/ }"
			if [ "${FINDKEYS}" = "ALL" ]; then
				jssh_deleteKeyDB "${CHAT[ID]}" "${TRACKFILE}"
				send_markdownv2_message "${CHAT[ID]}" "*Tracking gelöscht!*"
				return
			elif [[ "${FINDKEYS}" =~ ^[0-9]+$ ]]; then
			    if [ "${#KEYARR[@]}" -lt "${FINDKEYS}" ]; then
				send_normal_message "${CHAT[ID]}" "Es gibt nur $((${#KEYARR[@]}-1)) Keys, bitte nochmal."
				unset FINDKEYS
			    else
				send_normal_message "${CHAT[ID]}" "Lösche Key ${KEYARR[${FINDKEYS}]}"
				unset "KEYARR[0]"
				unset "KEYARR[${FINDKEYS}]"
				FINDKEYS="${KEYARR[*]}"
				if [ -z "${FINDKEYS}" ]; then
					jssh_deleteKeyDB "${CHAT[ID]}" "${TRACKFILE}"
					send_markdownv2_message "${CHAT[ID]}" "*Tracking gelöscht!*"
					return
				else
					KEY="${OLDKEYS#*!}"
					[ "${KEY}" != "${OLDKEYS}" ] && FINDKEYS+="|!${KEY}"
					MESSAGE="/newt ${FINDKEYS}"
				fi
			    fi
			else
			    OUT="$(printKeys "KEYARR")\n\nSchicke \"/delkey <Nr.>\" zum Löschen."
			    # send keyboard in private chats only
			    if [ "${CHAT[ID]}" != "${USER[ID]}" ]; then
				send_normal_message "${CHAT[ID]}" "${OUT}"
			    else
				send_keyboard "${CHAT[ID]}" "${OUT}"\
				'["/delkey 1","/delkey 2","/delkey 3"],["/delkey 4","/delkey 5","/delkey 6"],["/delkey 7","/delkey 8","/delkey 9"],["/delkey ALL","/delblack","/listtrack"]'
			    fi
			    return 1
			fi
			;;
	esac

	case "${MESSAGE}" in
		#######################
		# deal search commands
		'/such'*|'/sea'*) # suche
			FINDKEYS="${MESSAGE#/* }"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			    send_markdownv2_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			  if user_is_admin "${CHAT[ID]}" "${USER[ID]}" || user_is_allowed "${USER[ID]}" "search" "${CHAT[ID]}"; then
			    set_keys "${FINDKEYS}" "${SEARCHFILE}"
			  else
			    send_normal_message "${CHAT[ID]}" "${SORRYADMIN}"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			    return 1
			  fi
			fi
			return 1
			;;

		'/newt'*) # newtrack
			FINDKEYS="${MESSAGE#/* }"
			FINDKEYS="${FINDKEYS%[\" ]}"
			FINDKEYS="${FINDKEYS#[\" ]}"
			if [ "${FINDKEYS}" = "" ]; then 
			    send_markdownv2_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			    set_keys "${FINDKEYS}" "${TRACKFILE}"
			fi
			;&
		'/lst'*|'/listt'*) # listtrack
			send_action "${CHAT[ID]}" "typing"
			FINDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			if [ "${FINDKEYS}" = "" ]; then
			    send_markdownv2_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"
			    return
			fi
			OUT="Tracking nach \"${FINDKEYS}\" ist aktiv."
			# send keyboard in private chats only
			if [[ "${CHAT[ID]}" != "${USER[ID]}" ]]; then
			    send_normal_message "${CHAT[ID]}" "${OUT}"
			else
			    send_keyboard "${CHAT[ID]}" "${OUT}"\
			     '["/delkey 1","/delkey 2","/delkey 3"],["/delkey 4","/delkey 5","/delkey 6"],["/delkey 7","/delkey 8","/delkey 9"],["/delkey ALL","/delblack","/listtrack"]'
			fi
			return 1
			;;
	esac
     }

fi

    # place your processing functions here
    set_keys(){
	local MYFIND MYKEY MYKEYF MINLEN MYSEARCH
        declare -A KEYARR
	MYFIND="$1"
	MYKEYF="$2"
	MINLEN="4"
	# check len of keys
	for MYKEY in ${MYFIND}; do [ "${#MYKEY}" -lt "${MINLEN}" ] && break; done
	if [ "${#MYKEY}" -lt "${MINLEN}" ]; then
		send_markdownv2_message "${CHAT[ID]}" "*Ein Suchbegriff ist kürzer als ${MINLEN} Zeichen!*"
	else
		MYFIND="$(create_pattern "${MYFIND}")"
		[[ "${MESSAGE}" == "/s"* ]] &&\
			send_normal_message "${CHAT[ID]}" "Suche nach \"${MYFIND//|/ }\" wird gestartet ..."
		MYKEY="${MYFIND//[^|]}"
		if [ "${#MYKEY}" -gt 49 ]; then
		    send_markdownv2_message "${CHAT[ID]}" "*Maximale Anzahl von 50 Begriffen erreicht!*"
		elif [ "${MYFIND}" != "" ]; then
		    KEYARR["${CHAT[ID]}"]="${MYFIND}"
		    jssh_updateDB "KEYARR" "${MYKEYF}"
		else
		    send_markdownv2_message "${CHAT[ID]}" "*Ein Begriff ist ungültig, z.B. \" , oder leer!*"
		fi
	fi
    }
    # place your processing functions here

# $1 ARRAYNAME to print
printKeys() {
	local key
	declare -n ARRAY="$1"
	for key in "${!ARRAY[@]}"
       	do
		printf '%s  -  %s\n' "${key}" "${ARRAY[${key}]}"
       	done
}


# create a regex from space sepeareted keywords
# $1 space separated words
create_pattern() {
	local PATTERN KEY
	set -f
	for KEY in $1
	do
		[ "${PATTERN}" != "" ] && PATTERN="${PATTERN}|"
		PATTERN="${PATTERN}${KEY}"
	done
	set +f
	echo "${PATTERN}"
}

