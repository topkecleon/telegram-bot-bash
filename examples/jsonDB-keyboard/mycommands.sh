#!/bin/bash
# files: mycommands.sh.dist
# copy to mycommands.sh and add all your commands and functions here ...
#
#### $$VERSION$$ v1.2-0-gc50499c
#
# shellcheck disable=SC2154,SC2034,SC1117,SC2221,SC2222

# within *xxx* markup we need only one \ to escape a '_', e.g. my\_stupid\_bot (stupid V1 markup)
bashbot_title='*Hallo, ich bin der @'"${ME//_/\\_}"'. Ich suche und finde Dealz!*'

# outside *xxxx* markup we need two \\ to escape a '_', e.g. -> my\\_stupid\\_bot
bashbot_shelp="${bashbot_title}"'

Schicke mir hier -> @'"${ME//_/\\\\_}"' <- einen Befehl mit *max. 50 Begriffen*. Ein Begriff muss mindesten 4 Zeichen lang sein.

*Befehle zum Suchen / Tracken  von Dealz:*
  /search  /suche _Suche in Deals der letzen 48h,
  z.B.:_ /suche   Apple  mavic.\*air

  /newtrack   _Tracking mit neuen Begriffen,
  z.B.:_ /newtrack    Apple  mavic.\*air
  /track /addkey   _zusätzlicher Begriff zum Tracken_
  /addblack   _Begriff darf nicht vorkommen_
  /delkey       _lösche Begriff_
  /delblack   _lösche Blacklist Begriff_

  /listtrack   _zeigt aktuell getrackte Begriffe_
  /delkey ALL  _löscht alle Begriffe_ 
  /stattrack   _Infos zum aktiven Tracking_

Kurzform: /such /sea /newt /tra /addk /addb /delk /delb /lst /statt

*Platzhalter in Suchbegriffen:* 
    *.*\*  = egal/alles:  1tb*.*\*ssd
        ⇨ 1Tb-ssd, 1tb ssd,  1Tb Supi ssd
    *.*    = genau ein Zeichen: *.*tb 
        ⇨ 1Tb,  5TB,  atb, ztb
    *_*   = Wortanfang/end:  \\_Mavic\\_
        ⇨ das Wort  _Mavic_

Die Suche ignoriert Gross und Klein Schreibung, Satzzeichen, Klammern und "-", ebenso Links und Bilder. Mehr zu Regular Expressions (RegEx) http://www.regexe.de/hilfe.jsp
'

bashbot_whelp="${bashbot_title}"'

Schicke mir hier -> @'"${ME//_/\\\\_}"' <- einen Befehl mit *max. 50 Artikeln (ASIN)* zum Beobachten.

*Befehle zum Beobachten von Amzon Artikeln*

  /newwatch   _Beobachten neuer Artikel_
  z.B.:_ /newwatch    ASIN ASIN_
  /watch /addwatch   _weiteren Artikel beobachten_
  /delwatch     _löscht Artikel aus Beobachtung_

  /listwatch     _zeigt aktuell beobachtete Artikel_
  /delwatch ALL  _löscht alle Artikel_ 

  /notify        _einmalig warten bis Verfügar_
  /listnotify    _zeigt aktuell wartende Artikel_
  /delnotify     _löscht alle wartenden Artikel_

Kurzform: /neww /wat /addw /delw /listw /noti /listn /deln
'

bashbot_examples="${bashbot_title}"'

'

bashbot_group='*#MD Amazon Deutschland only Deals*
https://t.me/joinchat/IvvRtlEPhZKmWVVc8iTD2g

*#MD Zuhause, Family & Kids und Empfehlungen*
https://t.me/joinchat/IvvRtlT4f8HuwFDiJDCWoQ '

bashbot_all="${bashbot_title}"'

---------------------------------------------------------------------
'"${bashbot_group}"'

*#DL Amazon International*
https://t.me/joinchat/IvvRtkzPaMTHFZi3CjSX8g

*#MD Amazon Warehouse Schnäppchen *
https://t.me/joinchat/IvvRthRhj5NVkcihTxDZwQ

----------------------------------------------------------------------
Was hier kommt, kommt nur hier!

*#MD Kleidung, Accessoirs & Empfehlungen*
https://t.me/joinchat/IvvRthlJ8zwC7tHyhl63Fg

*#MD Mobilfunk & Smartphones*
https://t.me/joinchat/IvvRthtqth9Svyyvnb5lAQ

*#MD Gaming, Spiele & Konsolen*
https://t.me/joinchat/IvvRthRyrsmIyMFMc7189Q

---------------------------------------------------------------------
*#MD extrem - All Dealz über 100°*
https://t.me/joinchat/IvvRtk6ehHS4ZZmtoRFU2g

*#MD Offtopic: Diskussion & Ankündigungen*
https://t.me/joinchat/IvvRthRhMcX6rDQU-pZrWw

*Du willst Dealz suchen oder abbonieren?*
Klicke hier -> @'"${ME//_/\\\\_}"' <- und schicke /start
.
'

# uncomment the following lines to overwrite info and help messages
bashbot_info="${bashbot_title}"'

'"${bashbot_group}"'

*#MD Offtopic: Diskussion & Ankündigungen*
Hier kannst Du dich austauschen und erfährst Neues.
https://t.me/joinchat/IvvRthRhMcX6rDQU-pZrWw

*Du willst Dealz suchen oder tracken?*
Klicke hier -> @'"${ME//_/\\\\_}"' <- und schicke /start

*Meine Befehle*:
  /suche     _- Suchen und Tracken von Dealz_
  /watch     _- Beobachten von Amazon Artikeln_
  /gruppen  _- Liste aller Dealz Gruppen_
  /hilfe    _- Hilfe zu weiteren Befehlen_

*Dein '"${ME//_/-}"'*
https://dealz.rrr.de/amzdealz.html
'

bashbot_help="${bashbot_title}"'

Du hast eine eigene Telegram Dealgruppe? Lade mich ein und all in der Guppe können mich nutzen:

*verfügbare Befehle*:
 /suche     _- Suchen und Tracken von Dealz_
 /watch     _- Beobachten von Amazon Artikeln_
 /gruppen  _- Liste aller Dealz Gruppen_

 /info _- Info zum Bot_
 /help _- Zeigt diese Liste_

_https://dealz.rrr.de/assets/images/rdealomat.gif_
'

# in a regular message is no need to escape '_'
SORRYADMIN="Du bist kein Gruppenadmin, diesen Befehl kannst Du nur im privaten Chat ausführen @${ME} <<- hier klicken"
SORRYADMIN2="Dieser Befehl ist dem Botadmin vorbehalten, sorry."

# Set INLINE to 1 in order to receive inline queries.
# To enable this option in your bot, send the /setinline command to @BotFather.
INLINE=""
# Set to .* to allow sending files from all locations
FILE_REGEX='/home/deal-O-mat/.*'
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

export REMINDER="Del-O-Mat: https://dealz.rrr.de/amzdealz.html\n https://dealz.rrr.de/ebaydealz.html"

TRACKFILE="${DATADIR}/0-dealtrack"
SEARCHFILE="${DATADIR}/0-dealsearch"
WATCHFILE="${DATADIR}/0-dealwatch"
NOTIFYFILE="${DATADIR}/0-dealnotify"

if [ "$1" = "startbot" ];then
    # run once after startup when the first message is received
    my_startup(){
	# send reminder on startup, random delay
	send_normal_message "-10011894xxxxx" "${REMINDER}"
    }
    setConfigKey "startupaction" "await"
    # create KEYOFILE DB if not exist
    jssh_newDB "${TRACKFILE}"
    jssh_newDB "${SEARCHFILE}"
    jssh_newDB "${WATCHFILE}"
    jssh_newDB "${NOTIFYFILE}"
else
    # things to do only at source, eg. after startup
   if [[ "$(getConfigKey "startupaction")" != "done"* ]]; then
	setConfigKey "startupaction" "done $(date)"
	my_startup
    fi

    # your additional bashbot commands
    # NOTE: command can have @botname attached, you must add * in case tests... 
    mycommands() {
	# a service Message was received
	local SILENCER="yes"
	if [[ "${SERVICE}" != "" ]]; then
		# example: dleted service messages
		if [ "${SILENCER}" = "yes" ]; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# remove keyboard if you use keyboards
	[ -n "${REMOVEKEYBOARD}" ] && remove_keyboard "${CHAT[ID]}" "..." &
	[[ -n "${REMOVEKEYBOARD_PRIVATE}" &&  "${CHAT[ID]}" == "${USER[ID]}" ]] && remove_keyboard "${CHAT[ID]}" "..." &

	######################
	# default commands
	# fix upper case first letter in commands
	[[ "${MESSAGE}" =~  ^/[[:upper:]] ]] && MESSAGE="${MESSAGE:0:1}$(tr '[:upper:]' '[:lower:]' <<<"${MESSAGE:1:1}")${MESSAGE:2}"

	case "${MESSAGE}" in
		'/info'*)
			send_action "${CHAT[ID]}" "typing"
			delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			return 0 # continue with default action
			;;
		'/hel'*|'/hil'*)
			send_action "${CHAT[ID]}" "typing"
			delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			send_markdown_message "${CHAT[ID]}" "${bashbot_help}"
			return 1 # break, do not continue
			;;
		'/start'*)
			send_markdown_message "${CHAT[ID]}" "${bashbot_info}"
			return 1 # break, do not continue
			;;
		'/gr'*) # list groups
			delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			send_action "${CHAT[ID]}" "typing"
			send_markdown_message "${CHAT[ID]}" "${bashbot_all}"
			return
			;;
		#'/test'*)
		#	send_normal_message "${CHAT[ID]}" "Start interactive"
		#	send_markdown_message "${CHAT[ID]}" "TEST: äöüß!^°_-\"-,§$%&/(){}#@?[]{}._"
		#	return
		#	;;
		# will we process edited messages also?
		'/_edited_message'*)
			#return 1 # no
			# but if we do, remove /edited_message
			MESSAGE="${MESSAGE#/* }"
			;;
		'/_new_chat_member'*)
			if [[ -n "${WELCOME_NEWMEMBER}" && "${NEWMEMBER[ISBOT]}" != "true" ]]; then
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
		# must be in private chat, group admin, or botadmin
		'/sea'*|'/su'*|'/add'*|'/new'*|'/del'*|'/tra'*|'/wat'*|'/noti'*|'/lista'*)
			send_action "${CHAT[ID]}" "typing"
			if ! user_is_admin "${CHAT[ID]}" "${USER[ID]}" ; then
			    delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			    send_normal_message "${CHAT[ID]}" "${SORRYADMIN}"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			    return 1
			fi
			;;&
		# must be botadmin
		'/delu'*) 
			if ! user_is_botadmin "${USER[ID]}" ; then
			    delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			    send_markdown_message "${CHAT[ID]}" "*${SORRYADMIN2}*";
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			    return 1
			fi
			;;
	esac

	#################
	# search commands
	local FINDKEYS OLDKEYS KEY MYSENTID
	declare -a KEYARR
 	declare -A SEARCHVALUES

	#################
	# pre processing of search commands
	case "${MESSAGE}" in
		'/add'*|'/tra'*|'/noti'*) # add no arg
			FINDKEYS="${MESSAGE#/* }"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    send_normal_message "${CHAT[ID]}" "Kein Begriff angegeben!"
			    exit
			fi
			;;&
		'/addw'*|'/wat'*) OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${WATCHFILE}")"
			;;&
		'/add'[kbt]*|'/tra'*) OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			;;&
		'/noti'*) OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${NOTIFYFILE}")"
			;;&

		'/addk'*|'/addt'*|'/tra'*) # add track
			MESSAGE="/newtrack ${FINDKEYS} ${OLDKEYS}"
			;;
		'/addb'*) # add black
			[[ "${OLDKEYS}" != *'!'* ]] && FINDKEYS="!${FINDKEYS}"
			MESSAGE="/newtrack ${OLDKEYS} ${FINDKEYS}"
			;;
		'/addw'*|'/wat'*) # add watch
			FINDKEYS="${MESSAGE#/* }"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    delete_message  "${CHAT[ID]}"  "${MESSAGE[ID]}"
			    send_markdown_message "${CHAT[ID]}" "${bashbot_whelp}"
			    return
			fi
			MESSAGE="/newwatch ${FINDKEYS} ${OLDKEYS}"
			;;
		'/noti'*) # add watch
			MESSAGE="/newnotify ${FINDKEYS} ${OLDKEYS}"
			;;
		'/delk'*|'/delb'*) # no user search
			OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			if [ "${OLDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"
			    return
			fi
			;;&
		'/delw'*) # no watch
			OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${WATCHFILE}")"
			if [ "${OLDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Product Watch aktiv!*"
			    return
			fi
			;;&
		'/deln'*) # no notify
			OLDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${NOTIFYFILE}")"
			if [ "${OLDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Product Notify aktiv!*"
			    return
			fi
			jssh_deleteKeyDB "${CHAT[ID]}" "${NOTIFYFILE}"
			send_normal_message "${CHAT[ID]}" "Product Notify \"${OLDKEYS}\" gelöscht!"
			;;
		'/delk'*) #delete key
			KEY="${OLDKEYS%%|!*}"
			FINDKEYS="${MESSAGE#/* }"
			read -r -a KEYARR <<<"ALL ${KEY//|/ }"
			if [ "${FINDKEYS}" = "ALL" ]; then
				jssh_deleteKeyDB "${CHAT[ID]}" "${TRACKFILE}"
				send_markdown_message "${CHAT[ID]}" "*Tracking gelöscht!*"
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
					send_markdown_message "${CHAT[ID]}" "*Tracking gelöscht!*"
					return
				else
					KEY="${OLDKEYS#*!}"
					[ "${KEY}" != "${OLDKEYS}" ] && FINDKEYS+="|!${KEY}"
					MESSAGE="/newt ${FINDKEYS}"
				fi
			    fi
			else
			    OUT="Keys:\n$(printKeys "KEYARR")\n\nSchicke \"/delkey <Nr.>\" zum Löschen."
			    if [ "${CHAT[ID]}" != "${USER[ID]}" ]; then
				send_normal_message "${CHAT[ID]}" "${OUT}"
			    else
				send_keyboard "${CHAT[ID]}" "${OUT}"\
				'["/delkey 1","/delkey 2","/delkey 3"],["/delkey 4","/delkey 5","/delkey 6"],["/delkey 7","/delkey 8","/delkey 9"],["/delkey ALL","/delblack","/listtrack"]'
			    fi
			fi
			;;
		'/delb'*) #delete black
			KEY="${OLDKEYS#*!}"
			read -r -a KEYARR <<<"ALL ${KEY//|/ }"
			FINDKEYS="${MESSAGE#/* }"
			if [ "${KEY}" = "${OLDKEYS}" ]; then
				unset FINDKEYS
				unset KEYARR
				KEYARR[0]="Keine Blacklist"
			fi
			if [[ "${FINDKEYS}" =~ ^[0-9]+$ ]]; then
			    if [ "${#KEYARR[@]}" -lt "${FINDKEYS}" ]; then
				send_normal_message "${CHAT[ID]}" "Es gibt nur $((${#KEYARR[@]}-1)) Keys, bitte nochmal."
				unset "KEYARR[${FINDKEYS}]"
			    else
				send_normal_message "${CHAT[ID]}" "Lösche Black ${KEYARR[${FINDKEYS}]}"
				unset "KEYARR[0]"
				unset "KEYARR[${FINDKEYS}]"
				FINDKEYS="|!${KEYARR[*]}"
				[ "${FINDKEYS}" == "|!" ] && FINDKEYS=""
				MESSAGE="/newt ${OLDKEYS%%|!*}${FINDKEYS}"
			    fi
			fi
			if [[ -z "${FINDKEYS}" || "${FINDKEYS:0:1}" == "/" ]]; then # output list
			    OUT="Blacklist:\n$(printKeys "KEYARR")\n\nSchicke \"/delblack <Nr.>\" zum Löschen."
			    if [ "${CHAT[ID]}" != "${USER[ID]}" ]; then
				send_normal_message "${CHAT[ID]}" "${OUT}"
			    else
				send_keyboard "${CHAT[ID]}" "${OUT}"\
				'["/delblack 1","/delblack 2","/delblack 3"],["/delblack 4","/delblack 5","/delblack 6"],["/delblack 7","/delblack 8","/delblack 9"],["/delblack ALL","/delkey","/listtrack"]'
			    fi
			fi
			;;
		'/delw'*) #delete watch
			KEY="${OLDKEYS}"
			FINDKEYS="${MESSAGE#/* }"
			read -r -a KEYARR <<<"ALL ${KEY//|/ }"
			if [ "${FINDKEYS}" = "ALL" ]; then
				jssh_deleteKeyDB "${CHAT[ID]}" "${WATCHFILE}"
				send_markdown_message "${CHAT[ID]}" "*Produkt Watch gelöscht!*"
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
					jssh_deleteKeyDB "${CHAT[ID]}" "${WATCHFILE}"
					send_markdown_message "${CHAT[ID]}" "*Produkt Watch gelöscht!*"
					return
				else
					MESSAGE="/neww ${FINDKEYS}"
				fi
			    fi
			else
			    OUT="Keys:\n$(printKeys "KEYARR")\n\nSchicke \"/delwatch <Nr.>\" zum Löschen."
			    if [ "${CHAT[ID]}" != "${USER[ID]}" ]; then
				send_normal_message "${CHAT[ID]}" "${OUT}"
			    else
				send_keyboard "${CHAT[ID]}" "${OUT}"\
				'["/delwatch 1","/delwatch 2","/delwatch 3"],["/delwatch 4","/delwatch 5","/delwatch 6"],["/delwatch 7","/delwatch 8","/delwatch 9"],["/delwatch ALL","/listwatch"]'
			    fi
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
			    send_markdown_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			  if user_is_admin "${CHAT[ID]}" "${USER[ID]}" ; then
			    set_keys "${FINDKEYS}" "${SEARCHFILE}"
			  else
			    send_normal_message "${CHAT[ID]}" "${SORRYADMIN}"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			    return 1
			  fi
			fi
			return
			;;

		'/newt'*) # newtrack
			FINDKEYS="${MESSAGE#/* }"
			FINDKEYS="${FINDKEYS%[\" ]}"
			FINDKEYS="${FINDKEYS#[\" ]}"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    send_markdown_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			    set_keys "${FINDKEYS}" "${TRACKFILE}"
			fi
			;&
		'/lst'*|'/listt'*) # listtrack
			send_action "${CHAT[ID]}" "typing"
			FINDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${TRACKFILE}")"
			if [ "${FINDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"
			    return
			fi
			OUT="Tracking nach \"${FINDKEYS}\" ist aktiv."
			if [[ "${CHAT[ID]}" != "${USER[ID]}" ]]; then
			    send_normal_message "${CHAT[ID]}" "${OUT}"
			else
			    send_keyboard "${CHAT[ID]}" "${OUT}"\
			     '["/delkey 1","/delkey 2","/delkey 3"],["/delkey 4","/delkey 5","/delblack 6"],["/delblack 1","/delblack 2","/delblack 3"],["/delkey","/delblack","/listtrack"]'
			fi
			return
			;;
		'/neww'*) # newwatch
			FINDKEYS="${MESSAGE#/* }"
			FINDKEYS="${FINDKEYS%[\" ]}"
			FINDKEYS="${FINDKEYS#[\" ]}"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    send_markdown_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			    set_keys "${FINDKEYS}" "${WATCHFILE}"
			fi
			;&
		'/listw'*) # listwatch
			send_action "${CHAT[ID]}" "typing"
			FINDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${WATCHFILE}")"
			if [ "${FINDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Produkt Watch aktiv!*"
			    return
			fi
			OUT="Produkt Watch nach \"${FINDKEYS}\" ist aktiv."
			if [[ "${CHAT[ID]}" != "${USER[ID]}" ]]; then
			    send_normal_message "${CHAT[ID]}" "${OUT}"
			else
			    send_keyboard "${CHAT[ID]}" "${OUT}"\
			     '["/delwatch 1","/delwatch 2","/delwatch 3"],["/delwatch 4","/delwatch 5","/delwatch 6"],["/delwatch 7","/delwatch 8","/delwatch 9"],["/delwatch","/delwatch ALL","/listwatch"]'
			fi
			return
			;;
		'/newn'*) # newnotify
			FINDKEYS="${MESSAGE#/* }"
			FINDKEYS="${FINDKEYS%[\" ]}"
			FINDKEYS="${FINDKEYS#[\" ]}"
			if [ "${FINDKEYS}" = "${MESSAGE}" ]; then 
			    send_markdown_message "${CHAT[ID]}" "${bashbot_shelp}"
			else
			    set_keys "${FINDKEYS}" "${NOTIFYFILE}"
			fi
			;&
		'/listn'*) # listnotify
			send_action "${CHAT[ID]}" "typing"
			FINDKEYS="$(jssh_getKeyDB "${CHAT[ID]}" "${NOTIFYFILE}")"
			if [ "${FINDKEYS}" = "" ]; then
			    send_markdown_message "${CHAT[ID]}" "*Kein Produkt Notify aktiv!*"
			    return
			fi
			OUT="Produkt Notify nach \"${FINDKEYS}\" ist aktiv."
			send_normal_message "${CHAT[ID]}" "${OUT}"
			return
			;;

		#############################
		# botadmin only commands
		'/listat'*) # listalltrack
			jssh_readDB "SEARCHVALUES" "${TRACKFILE}"
			FINDKEYS="$(jssh_printDB "SEARCHVALUES")"
			if [ "${FINDKEYS}" != "" ]; then
			    # shellcheck disable=SC2126
			    send_action "${CHAT[ID]}" "typing"
			    send_normal_message "${CHAT[ID]}" "All Suchaufträge:\n${FINDKEYS}"
			else
			    send_markdown_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"
			fi
			;;
		'/listaw'*) # listall watch
			jssh_readDB "SEARCHVALUES" "${WATCHFILE}"
			FINDKEYS="$(jssh_printDB "SEARCHVALUES")"
			if [ "${FINDKEYS}" != "" ]; then
			    send_action "${CHAT[ID]}" "typing"
			    send_normal_message "${CHAT[ID]}" "Alle Watchaufträge:\n${FINDKEYS}"
			else
			    send_markdown_message "${CHAT[ID]}" "*Kein Produkt Watch aktiv!*"
			fi
			return
			;;
		'/delu'*) # delusersearch
			KEY="${MESSAGE#/* }"; KEY="${KEY#%% *}"
			if [ "${KEY}" = "${MESSAGE}" ] || [ "${KEY}" = "" ] ; then
			    jssh_readDB "SEARCHVALUES" "${TRACKFILE}"
			    FINDKEYS="$(jssh_printDB "SEARCHVALUES")"
			    if [ "${FINDKEYS}" != "" ]; then
				send_normal_message "${CHAT[ID]}"\
					"Aktive Suchaufträge:\n${FINDKEYS}\n\nSende \"/deluser ID\" zum Löschen eines Users"
			    else
				send_markdown_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"; exit
			    fi
			    exit
			fi
			jssh_deleteKeyDB "${KEY}" "${TRACKFILE}"
			send_normal_message "${CHAT[ID]}" "Lösche Suchauftrag User ${KEY}"
			jssh_readDB "SEARCHVALUES" "${TRACKFILE}"
			FINDKEYS="$(jssh_printDB "SEARCHVALUES")"
			if [ "${FINDKEYS}" != "" ]; then
			    send_normal_message "${CHAT[ID]}" "Verbliebene Suchaufträge:\n${FINDKEYS}"
			else
			    send_markdown_message "${CHAT[ID]}" "*Kein Tracking aktiv!*"; exit
			fi
			return
			;;

	esac

     }

fi

    # debug function called on start, stop of bot, interactive and  background processes
    # if your bot was started with debug as second argument
    # $1 current date, $2 from where the function wqs called, $3 ... $n optional information
    my_debug_checks() {
	# example check because my bot creates a wrong file, this was becuase an empty variable
	[ -f ".jssh" ] && printf "%s: %s\n" "${1}" "Ups, found file \"${PWD:-.}/.jssh\"! =========="
    }

    # called when bashbot sedn command failed because we can not connect to telegram
    # return 0 to retry, return non 0 to give up
    bashbotBlockRecover() {
	# place your commnds to unblock here, e.g. change IP or simply wait
	sleep 60 && return 0 # may be temporary
	return 1 
    }

    # place your processing functions here
    set_keys(){
	local MYFIND MYKEY MYKEYF MINLEN MYCHECK MYSEARCH
        declare -A KEYARR
	MYFIND="$1"
	MYKEYF="$2"
	MINLEN="3"
	# check len of keys
	for MYKEY in ${MYFIND}; do [ "${#MYKEY}" -lt ${MINLEN} ] && break; done
	if [ "${#MYKEY}" -lt ${MINLEN} ]; then
		send_markdown_message "${CHAT[ID]}" "*Ein Suchbegriff ist kürzer als ${MINLEN} Zeichen!*"
	else
		MYFIND="$(create_pattern "${MYFIND}")"
		MYCHECK="$(check_pattern "${MYFIND}")"
		[[ "${MESSAGE}" == "/s"* ]] &&\
			send_normal_message "${CHAT[ID]}" "${MYCHECK}Suche nach \"${MYFIND//|/ }\" wird gestartet ..."
		MYKEY="${MYFIND//[^|]}"
		if [ "${#MYKEY}" -gt 49 ]; then
		    send_markdown_message "${CHAT[ID]}" "*Maximale Anzahl von 50 Begriffen erreicht!*"
		elif [ "${MYFIND}" != "" ]; then
		    KEYARR["${CHAT[ID]}"]="${MYFIND}"
		    jssh_updateDB "KEYARR" "${MYKEYF}"
		    #jssh_insertDB "${CHAT[ID]}" "${MYFIND}" "${MYKEYF}"
		else
		    send_markdown_message "${CHAT[ID]}" "*Ein Begriff ist ungültig, z.B. \" , oder leer!*"
		fi
	fi
    }
    # place your processing functions here


    # $1 ARRAYNAME $2 command
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
	# revome blank and "
	PATTERN="${PATTERN//[\" ]}"
	# remove * at start
	PATTERN="${PATTERN//|\*/|}"; PATTERN="${PATTERN#\*}"
	# remove unneeded |
	PATTERN="${PATTERN//||/|}"; PATTERN="${PATTERN#|}"; PATTERN="${PATTERN%|}"
	set +f
	echo "${PATTERN}"
    }

    # check regex for common errors
    # ¤1 pattern
    check_pattern() {
	local WARN=""
	if [[ "$1" =~ ([^.\)]\*)|(^\*) ]]; then
		WARN+="Meintest du evtl. '.*' ?  '*' ist vorheriges Zeichen beliebig oft. "$'\n\r'
	fi
	if [[ "$1" =~ (^\*)|(^.\*)|([^\)]\*\|)|(\|\*)|(\|\.\*)|([^\)]\*$) ]] ; then
		WARN+="Ein '.*' oder '*' an Anfang oder End ist unnötig. "$'\n\r'
	fi
	if [[ "$1" =~ \([^|\)]*\| ]] ; then
		WARN+="Öffnende '(' ohne ')' gefunden. Klammerausdruck muss vor '|' geschlossen sein. "$'\n\r'
	fi
	[ -n "${WARN}" ] && printf "Potentielle Fehlerquellen:\n\r%s\n\r" "${WARN}"
    }
