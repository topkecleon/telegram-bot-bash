#!/bin/bash
# file: modules/inline.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28

# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"


answer_inline_query() {
	answer_inline_multi "$1" "$(shift; inline_query_compose "${RANDOM}" "$@")"
}
answer_inline_multi() {
	sendJson "" '"inline_query_id": '"$1"', "results": ['"$2"']' "${URL}/answerInlineQuery"
}

# $1 unique ID for answer
# $2 type of answer
# remaining arguments are the "must have" arguments in the order as in telegram doc
# followed by the optional arguments: https://core.telegram.org/bots/api#inlinequeryresult
inline_query_compose(){
	local JSON="{}"
	local ID="$1"
	local fours last
								# title2Json title caption description markup inlinekeyboard
	case "$2" in
		# user provided media
		"article"|"message")	# article ID title message (markup description)
			JSON='{"type":"article","id":"'${ID}'","input_message_content": {"message_text":"'$4'"} '$(title2Json "$3" "" "$5" "$6" "$7")'}'
		;;
		"photo")	# photo ID photoURL (thumbURL title description caption)
			[ -z "$4" ] && tumb="$3"
			JSON='{"type":"photo","id":"'${ID}'","photo_url":"'$3'","thumb_url":"'$4${tumb}'"'$(title2Json "$5" "$7" "$6" "$7" "$8")'}'
		;;
		"gif")	# gif ID photoURL (thumbURL title caption)
			[ -z "$4" ] && tumb="$3"
			JSON='{"type":"gif","id":"'${ID}'","gif_url":"'$3'", "thumb_url":"'$4${tumb}'"'$(title2Json "$5" "$6" "$7" "$8" "$9")'}'
		;;
		"mpeg4_gif")	# mpeg4_gif ID mpegURL (thumbURL title caption)
			[ -n "$4" ] && tumb='","thumb_url":"'$4'"'
			JSON='{"type":"mpeg4_gif","id":"'${ID}'","mpeg4_url":"'$3'"'${tumb}$(title2Json "$5" "$6" "" "$7" "$8")'}'
		;;
		"video")	# video ID videoURL mime thumbURL title (caption)
			JSON='{"type":"video","id":"'${ID}'","video_url":"'$3'","mime_type":"'$4'","thumb_url":"'$5'"'$(title2Json "$6" "$7" "$8" "$9" "${10}")'}'
		;;
		"audio")	# audio ID audioURL title (caption)
			JSON='{"type":"audio","id":"'${ID}'","audio_url":"'$3'"'$(title2Json "$4" "$5" "" "" "$6")'}'
		;;
		"voice")	# voice ID voiceURL title (caption)
			JSON='{"type":"voice","id":"'${ID}'","voice_url":"'$3'"'$(title2Json "$4" "$5" "" "" "$6")'}'
		;;
		"document")	# document ID title documentURL mimetype (caption description)
			JSON='{"type":"document","id":"'${ID}'","document_url":"'$4'","mime_type":"'$5'"'$(title2Json "$3" "$6" "$7" "$8" "$9")'}'
		;;
		"location")	# location ID lat long title
			JSON='{"type":"location","id":"'${ID}'","latitude":"'$3'","longitude":"'$4'","title":"'$5'"}'
		;;
		"venue")	# venue ID lat long title (address forsquare)
			[ -z "$6" ] && addr="$5"
			[ -n "$7" ] && fours=',"foursquare_id":"'$7'"'
			JSON='{"type":"venue","id":"'${ID}'","latitude":"'$3'","longitude":"'$4'","title":"'$5'","address":"'$6${addr}'"'${fours}'}'
		;;
		"contact")	# contact ID phone first (last thumb)
			[ -n "$5" ] && last=',"last_name":"'$5'"'
			[ -n "$6" ] && tumb='","thumb_url":"'$6'"'
			JSON='{"type":"contact","id":"'${ID}'","phone_number":"'$3'","first_name":"'$4'"'${last}'"}'
		;;
								# title2Json title caption description markup inlinekeyboard
		# Cached media stored in Telegram server
		"cached_photo")	# photo ID file (title description caption)
			JSON='{"type":"photo","id":"'${ID}'","photo_file_id":"'$3'"'$(title2Json "$4" "$6" "$5"  "$7" "$8")'}'
		;;
		"cached_gif")	# gif ID file (title caption)
			JSON='{"type":"gif","id":"'${ID}'","gif_file_id":"'$3'"'$(title2Json "$4" "$5" "$6" "$7" "$8" )'}'
		;;
		"cached_mpeg4_gif")	# mpeg ID file (title caption)
			JSON='{"type":"mpeg4_gif","id":"'${ID}'","mpeg4_file_id":"'$3'"'$(title2Json "$4" "$5"  "" "$6" "$7")'}'
		;;
		"cached_sticker")	# sticker ID file 
			JSON='{"type":"sticker","id":"'${ID}'","sticker_file_id":"'$3'"}'
		;;
		"cached_document")	# document ID title file (description caption)
			JSON='{"type":"document","id":"'${ID}'","document_file_id":"'$4'"'$(title2Json "$3" "$6" "$5"  "$6" "$7")'}'
		;;
		"cached_video")	# video ID file title (description caption)
			JSON='{"type":"video","id":"'${ID}'","video_file_id":"'$3'"'$(title2Json "$4" "$6" "$5" "$7" "$8")'}'
		;;
		"cached_voice")	# voice ID file title (caption)
			JSON='{"type":"voice","id":"'${ID}'","voice_file_id":"'$3'"'$(title2Json "$4" "$5" "" "" "$6")'}'
		;;
		"cached_audio")	# audio ID file title (caption)
			JSON='{"type":"audio","id":"'${ID}'","audio_file_id":"'$3'"'$(title2Json "$4" "$5" "" "" "$6")'}'
		;;
	esac

	printf '%s\n' "${JSON}"
}

