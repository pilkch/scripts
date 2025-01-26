#!/bin/bash -xe

URL_OR_IDENTIFIER="$1"
if [ "$URL_OR_IDENTIFIER" = "" ]; then
  echo "Usage: ./download-mp4.sh URL_OR_IDENTIFIER [TIMESTAMPS]"
  echo ""
  echo "TIMESTAMPS - Begin and end times, for example: 6:02-6:22"
  exit 1
fi

TIMESTAMPS="$2"

if [ "$TIMESTAMPS" = "" ]; then
  #youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '%(title)s' "$URL_OR_IDENTIFIER"
  # Download the best mp4 video available, or the best video if no mp4 available
  yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b" -S "ext" -o "%(title)s.%(ext)s" --embed-metadata --no-embed-info-json --embed-thumbnail "$URL_OR_IDENTIFIER"
else
  # Download the best mp4 video available, or the best video if no mp4 available
  yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b" -S "ext" -o "%(title)s.%(ext)s" --embed-metadata --no-embed-info-json --embed-thumbnail --download-sections "*$TIMESTAMPS" "$URL_OR_IDENTIFIER"
fi
