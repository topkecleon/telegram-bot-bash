#!/bin/bash
# file: modules/inline.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.70-10-gcbdfc7c

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
# remaining arguments are in the order as shown in telegram doc: https://core.telegram.org/bots/api#inlinequeryresult
inline_query_compose(){
	local JSON="{}"
	local ID="${1}"
	case "${2}" in
		# user provided media
		"article")
			local parse=',"parse_mode":'"${5}" && [ "${5}" = "" ] && parse=""
			JSON='{"type":"article","id":"'$ID'","title":"'$3'","message_text":"'$4'"'"${parse}"'}'
		;;
		"photo")
			[ "$4" = "" ] && local tumb="$3"
			JSON='{"type":"photo","id":"'$ID'","photo_url":"'$3'","thumb_url":"'$4${tumb}'"}'
		;;
		"gif")
			[ "$4" = "" ] && local tumb="$3"
			JSON='{"type":"gif","id":"'$ID'","gif_url":"'$3'", "thumb_url":"'$4${tumb}'"}'
		;;
		"mpeg4_gif")
			JSON='{"type":"mpeg4_gif","id":"'$ID'","mpeg4_url":"'$3'"}'
		;;
		"video")
			[ "$5" = "" ] && local tumb="$3"
			JSON='{"type":"video","id":"'$ID'","video_url":"'$3'","mime_type":"'$4'","thumb_url":"'$5${tumb}'","title":"'$6'"}'
		;;
		"audio")
			JSON='{"type":"audio","id":"'$ID'","audio_url":"'$3'","title":"'$4'"}'
		;;
		"voice")
			JSON='{"type":"voice","id":"'$ID'","voice_url":"'$3'","title":"'$4'"}'
		;;
		"document")
			JSON='{"type":"document","id":"'$ID'","title":"'$3'","caption":"'$4'","document_url":"'$5'","mime_type":"'$6'"}'
		;;
		"location")
			JSON='{"type":"location","id":"'$ID'","latitude":"'$3'","longitude":"'$4'","title":"'$5'"}'
		;;
		"venue")
			[ "$6" = "" ] && local addr="$5"
			JSON='{"type":"venue","id":"'$ID'","latitude":"'$3'","longitude":"'$4'","title":"'$5'","address":"'$6${addr}'"}'
		;;
		"contact")
			JSON='{"type":"contact","id":"'$ID'","phone_number":"'$3'","first_name":"'$4'","last_name":"'$5'"}'
		;;
		# Cached media stored in Telegram server
		"cached_photo")
			JSON='{"type":"photo","id":"'$ID'","photo_file_id":"'$3'"}'
		;;
		"cached_gif")
			JSON='{"type":"gif","id":"'$ID'","gif_file_id":"'$3'"}'
		;;
		"cached_mpeg4_gif")
			JSON='{"type":"mpeg4_gif","id":"'$ID'","mpeg4_file_id":"'$3'"}'
		;;
		"cached_sticker")
			JSON='{"type":"sticker","id":"'$ID'","sticker_file_id":"'$3'"}'
		;;
		"cached_document")
			JSON='{"type":"document","id":"'$ID'","title":"'$3'","document_file_id":"'$4'"}'
		;;
		"cached_video")
			JSON='{"type":"video","id":"'$ID'","video_file_id":"'$3'","title":"'$4'"}'
		;;
		"cached_voice")
			JSON='{"type":"voice","id":"'$ID'","voice_file_id":"'$3'","title":"'$4'"}'
		;;
		"cached_audio")
			JSON='{"type":"audio","id":"'$ID'","audio_file_id":"'$3'"}'
		;;
	esac

	echo "${JSON}"
}

