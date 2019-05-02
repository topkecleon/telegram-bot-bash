#!/bin/bash
# file: modules/inline.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.80-dev-3-g9bcab66

# source from commands.sh to use the inline functions

INLINE_QUERY=$URL'/answerInlineQuery'
declare -A iQUERY
export iQUERY

process_inline() {
echo "$UPDATE" >>INLINE.log
	iQUERY[0]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"$PROCESS_NUMBER"',"inline_query","query"')")"
	iQUERY[USER_ID]="$(JsonGetString <<<"${UPDATE}" '"result",'"$PROCESS_NUMBER"',"inline_query","from","id"')"
	iQUERY[FIRST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"$PROCESS_NUMBER"',"inline_query","from","first_name"')")"
	iQUERY[LAST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"$PROCESS_NUMBER"',"inline_query","from","last_name"')")"
	iQUERY[USERNAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"$PROCESS_NUMBER"',"inline_query","from","username"')")"
}


answer_inline_query() {
	local JSON
	case "${2}" in
		"article")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","title":"'$3'","message_text":"'$4'"}]'
		;;
		"photo")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","photo_url":"'$3'","thumb_url":"'$4'"}]'
		;;
		"gif")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","gif_url":"'$3'", "thumb_url":"'$4'"}]'
		;;
		"mpeg4_gif")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","mpeg4_url":"'$3'"}]'
		;;
		"video")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","video_url":"'$3'","mime_type":"'$4'","thumb_url":"'$5'","title":"'$6'"}]'
		;;
		"audio")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","audio_url":"'$3'","title":"'$4'"}]'
		;;
		"voice")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","voice_url":"'$3'","title":"'$4'"}]'
		;;
		"document")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","title":"'$3'","caption":"'$4'","document_url":"'$5'","mime_type":"'$6'"}]'
		;;
		"location")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","latitude":"'$3'","longitude":"'$4'","title":"'$5'"}]'
		;;
		"venue")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","latitude":"'$3'","longitude":"'$4'","title":"'$5'","address":"'$6'"}]'
		;;
		"contact")
			JSON='[{"type":"'$2'","id":"'$RANDOM'","phone_number":"'$3'","first_name":"'$4'"}]'
		;;

		# Cached media stored in Telegram server

		"cached_photo")
			JSON='[{"type":"photo","id":"'$RANDOM'","photo_file_id":"'$3'"}]'
		;;
		"cached_gif")
			JSON='[{"type":"gif","id":"'$RANDOM'","gif_file_id":"'$3'"}]'
		;;
		"cached_mpeg4_gif")
			JSON='[{"type":"mpeg4_gif","id":"'$RANDOM'","mpeg4_file_id":"'$3'"}]'
		;;
		"cached_sticker")
			JSON='[{"type":"sticker","id":"'$RANDOM'","sticker_file_id":"'$3'"}]'
		;;
		"cached_document")
			JSON='[{"type":"document","id":"'$RANDOM'","title":"'$3'","document_file_id":"'$4'"}]'
		;;
		"cached_video")
			JSON='[{"type":"video","id":"'$RANDOM'","video_file_id":"'$3'","title":"'$4'"}]'
		;;
		"cached_voice")
			JSON='[{"type":"voice","id":"'$RANDOM'","voice_file_id":"'$3'","title":"'$4'"}]'
		;;
		"cached_audio")
			JSON='[{"type":"audio","id":"'$RANDOM'","audio_file_id":"'$3'"}]'
		;;

	esac

	sendJson "" '"inline_query_id": '"${1}"', "results": '"${JSON}" "${INLINE_QUERY}"
}

