#!/bin/bash -xe

URL_OR_IDENTIFIER="$1"
if [ "$URL_OR_IDENTIFIER" = "" ]; then
  echo "Usage: ./download-wav.sh URL_OR_IDENTIFIER [TIMESTAMPS]"
  echo ""
  echo "TIMESTAMPS - Begin and end times, for example: 6:02-6:22"
  exit 1
fi

TIMESTAMPS="$2"

if [ "$TIMESTAMPS" = "" ]; then
  youtube-dl -f bestaudio --extract-audio --audio-format wav --audio-quality 0 -o '%(title)s.%(ext)s' "$URL_OR_IDENTIFIER"
else
  yt-dlp --extract-audio -S "ext" -o "%(title)s.%(ext)s" --download-sections "*$TIMESTAMPS" "$URL_OR_IDENTIFIER"
fi
