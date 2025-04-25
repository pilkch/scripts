#!/bin/bash -xe
#
# Creates a virtual pipewire device so that applications can output to that, then the virtual device can output to multiple physical output devices
# This script is based on: https://github.com/majoranimal/PipeWire-Audio-Router/tree/main
# NOTE: This just creates the virtual device, but doesn't hook it up to anything, you need to use helvum or some other application to actually hook it up

INPUTNAME="virt-input"
OUTPUTNAME="virt-output"

# Creates a virtual input
pactl load-module module-null-sink media.class=Audio/Sink sink_name=$INPUTNAME channel_map=stereo

# Creates a virtual output
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=$OUTPUTNAME channel_map=front-left,front-right

# Links the virtual input to the virtual output
pw-link $INPUTNAME:monitor_FL $OUTPUTNAME:input_FL
pw-link $INPUTNAME:monitor_FR $OUTPUTNAME:input_FR


# The virtual device is now set up, the user needs to:
# 1. Run helvum or similar to set up the links between the virtual device and the 1..n physical output devices
# 2. Change the default output device in your sound manager
