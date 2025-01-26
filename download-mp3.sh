#!/bin/bash -xe

URL_OR_IDENTIFIER="$1"
if [ "$URL_OR_IDENTIFIER" = "" ]; then
  echo "Usage: ./download-mp3.sh URL_OR_IDENTIFIER [TIMESTAMPS]"
  echo ""
  echo "TIMESTAMPS - Begin and end times, for example: 6:02-6:22"
  exit 1
fi

TIMESTAMPS="$2"

if [ "$TIMESTAMPS" = "" ]; then
  #youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' "$URL_OR_IDENTIFIER"
  yt-dlp --extract-audio --audio-format mp3 -S "ext" -o "%(title)s.%(ext)s" --embed-metadata --no-embed-info-json "$URL_OR_IDENTIFIER"
else
  yt-dlp --extract-audio --audio-format mp3 -S "ext" -o "%(title)s.%(ext)s" --embed-metadata --no-embed-info-json --download-sections "*$TIMESTAMPS" "$URL_OR_IDENTIFIER"
fi
