#!/bin/sh
printf '\033c\033]0;%s\a' Hotline Miami
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Hotline Miami.x86_64" "$@"
