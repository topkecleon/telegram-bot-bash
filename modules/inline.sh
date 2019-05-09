#!/bin/bash
# file: modules/inline.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.72-dev-0-g6afa177

# source from commands.sh to use the inline functions

INLINE_QUERY=$URL'/answerInlineQuery'
declare -A iQUERY
export iQUERY

process_inline() {
	local num="${1}"
	iQUERY[0]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",0,"inline_query","query"')")"
	iQUERY[USER_ID]="$(JsonGetValue <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","id"')"
	iQUERY[FIRST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","first_name"')")"
	iQUERY[LAST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","last_name"')")"
	iQUERY[USERNAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","username"')")"
}


answer_inline_query() {
	answer_inline_multi "${1}" "$(shift; inline_query_compose "$RANDOM" "$@")"
}
answer_inline_multi() {
	sendJson "" '"inline_query_id": '"${1}"', "results": ['"${2}"']' "${INLINE_QUERY}"
}

# $1 unique ID for answer
# $2 type of answer
# remaining arguments are the "must have" arguments in the order as in telegram doc
# followed by the optional arguments: https://core.telegram.org/bots/api#inlinequeryresult
inline_query_compose(){
	local JSON="{}"
	local ID="${1}"
	local title markup caption fours last desc
	case "${2}" in
		# user provided media
		"article"|"message") # article ID title message (markup decription)
			[ "$5" != "" ] && markup=',"parse_mode":'"$5"
			[ "$6" != "" ] && desc=',"description":"'$6'"'
			JSON='{"type":"article","id":"'$ID'","title":"'$3'","message_text":"'$4'"'${markup}${desc}'}'
		;;
		"photo") # photo ID photoURL (thumbURL title description caption)
			[ "$4" = "" ] && tumb="$3"
			[ "$5" != "" ] && title=',"title":"'$5'"'
			[ "$6" != "" ] && desc=',"description":"'$6'"'
			[ "$7" != "" ] && caption=',"caption":"'$7'"'
			JSON='{"type":"photo","id":"'$ID'","photo_url":"'$3'","thumb_url":"'$4${tumb}'"'${title}${desc}${caption}'}'
		;;
		"gif") # gif ID photoURL (thumbURL title caption)
			[ "$4" = "" ] && tumb="$3"
			[ "$5" != "" ] && title=',"title":"'$5'"'
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			JSON='{"type":"gif","id":"'$ID'","gif_url":"'$3'", "thumb_url":"'$4${tumb}'"'${title}${caption}'}'
		;;
		"mpeg4_gif") # mpeg4_gif ID mpegURL (thumbURL title caption)
			[ "$4" != "" ] && tumb='","thumb_url":"'$4'"'
			[ "$5" != "" ] && title=',"title":"'$5'"'
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			JSON='{"type":"mpeg4_gif","id":"'$ID'","mpeg4_url":"'$3'"'${tumb}${title}${caption}'}'
		;;
		"video") # video ID videoURL mime thumbURL title (caption)
			[ "$7" != "" ] && caption=',"caption":"'$7'"'
			JSON='{"type":"video","id":"'$ID'","video_url":"'$3'","mime_type":"'$4'","thumb_url":"'$5'","title":"'$6'"'${caption}'}'
		;;
		"audio") # audio ID audioURL title (caption)
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"audio","id":"'$ID'","audio_url":"'$3'","title":"'$4'"'${caption}'}'
		;;
		"voice") # voice ID voiceURL title (caption)
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"voice","id":"'$ID'","voice_url":"'$3'","title":"'$4'"'${caption}'}'
		;;
		"document") # document ID title documentURL mimetype (caption description)
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			[ "$7" != "" ] && desc=',"description":"'$7'"'
			JSON='{"type":"document","id":"'$ID'","title":"'$3'","document_url":"'$4'","mime_type":"'$5'"'${caption}${desc}'}'
		;;
		"location") # location ID lat long title
			JSON='{"type":"location","id":"'$ID'","latitude":"'$3'","longitude":"'$4'","title":"'$5'"}'
		;;
		"venue") # venue ID lat long title (adress forsquare)
			[ "$6" = "" ] && addr="$5"
			[ "$7" != "" ] && fours=',"foursquare_id":"'$7'"'
			JSON='{"type":"venue","id":"'$ID'","latitude":"'$3'","longitude":"'$4'","title":"'$5'","address":"'$6${addr}'"'${fours}'}'
		;;
		"contact") # contact ID phone first (last thumb)
			[ "$5" != "" ] && last=',"last_name":"'$5'"'
			[ "$6" != "" ] && tumb='","thumb_url":"'$6'"'
			JSON='{"type":"contact","id":"'$ID'","phone_number":"'$3'","first_name":"'$4'"'${last}'"}'
		;;
		# Cached media stored in Telegram server
		"cached_photo") # photo ID file (title description caption)
			[ "$4" != "" ] && title=',"title":"'$4'"'
			[ "$5" != "" ] && desc=',"description":"'$5'"'
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			JSON='{"type":"photo","id":"'$ID'","photo_file_id":"'$3'"'${title}${desc}${caption}'}'
		;;
		"cached_gif") # gif ID file (title caption)
			[ "$4" != "" ] && title=',"title":"'$4'"'
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"gif","id":"'$ID'","gif_file_id":"'$3'"'${title}${caption}'}'
		;;
		"cached_mpeg4_gif") # mpeg ID file (title caption)
			[ "$4" != "" ] && title=',"title":"'$4'"'
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"mpeg4_gif","id":"'$ID'","mpeg4_file_id":"'$3'"'${title}${caption}'}'
		;;
		"cached_sticker") # sticker ID file 
			JSON='{"type":"sticker","id":"'$ID'","sticker_file_id":"'$3'"}'
		;;
		"cached_document") # document ID title file (description caption)
			[ "$5" != "" ] && desc=',"description":"'$5'"'
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			JSON='{"type":"document","id":"'$ID'","title":"'$3'","document_file_id":"'$4'"'${desc}${caption}'}'
		;;
		"cached_video") # video ID file title (description caption)
			[ "$5" != "" ] && desc=',"description":"'$5'"'
			[ "$6" != "" ] && caption=',"caption":"'$6'"'
			JSON='{"type":"video","id":"'$ID'","video_file_id":"'$3'","title":"'$4'"'${desc}${caption}'}'
		;;
		"cached_voice") # voice ID file title (caption)
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"voice","id":"'$ID'","voice_file_id":"'$3'","title":"'$4'"'${caption}'}'
		;;
		"cached_audio") # audio ID file title (caption)
			[ "$5" != "" ] && caption=',"caption":"'$5'"'
			JSON='{"type":"audio","id":"'$ID'","audio_file_id":"'$3'"'${caption}'}'
		;;
	esac

	echo "${JSON}"
}

