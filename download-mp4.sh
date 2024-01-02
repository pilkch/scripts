#!/bin/bash -xe

URL_OR_IDENTIFIER="$1"
if [ "$URL_OR_IDENTIFIER" = "" ]; then
  echo "Usage: ./download-mp4.sh URL_OR_IDENTIFIER"
  exit 1
fi

youtube-dl --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o '%(title)s' "$URL_OR_IDENTIFIER"
