#!/bin/bash

function create_list_of_files {
    # Too many files for the "file" command, so we create a file that is just a list of the mp3 files
    find -name "*.mp3" > mp3files.txt
}

function check_list_of_files {
    echo "" > mp3errorfiles.txt

    while read FILE; do
    OUTPUT=$(file "$FILE")
    if [[ "$OUTPUT" != *"ID3"* ]] && [[ "$OUTPUT" != *"layer III"* ]]; then
        # Output to the screen
        echo "$OUTPUT"

        # Output to our errors file
        echo "$FILE" >> mp3errorfiles.txt
    fi
    done <mp3files.txt
}

create_list_of_files
check_list_of_files
