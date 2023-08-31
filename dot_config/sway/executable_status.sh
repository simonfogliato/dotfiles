#!/bin/bash
status_volume="\"volume\": \"`wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/^Volume: //'`\""
status_swaync="\"swaync\": `swaync-client -D`"
status_epoch="\"epoch\": `date +'%s'`"
status_date="\"date\": \"`date +'%a %d %b %Y %r %Z'`\""
if [ "$(upower --enumerate | grep -c BAT)" -ne "0" ]; then
	status_power="\"power\": \"`upower --show-info $(upower --enumerate | grep BAT) | grep percentage | awk '{print $2}'`\""
	status_brightness="\"brightness\": \"`brightnessctl info | grep 'Current brightness' | awk '{ print $4}' | tr -d '()'`\""
	echo "{ $status_power, $status_brightness, $status_volume, $status_swaync, $status_epoch, $status_date }"
else
	echo "{ $status_volume, $status_swaync, $status_epoch, $status_date }"
fi
