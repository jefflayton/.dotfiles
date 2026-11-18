#!/bin/sh
# Rex Open: open files in nvim in a new Rex tab, starting in the first file's folder.
# The session picker is the rex_open action in open.lua.
set -eu

rex="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

open -b com.superlogical.rex
[ $# -eq 0 ] && exit 0
sleep 0.5 # a prompt that arrives while Rex is still coming to the front is cancelled at once

first=${1%/}
if [ -d "$first" ]; then cwd=$first; else cwd=$(dirname -- "$first"); fi
"$rex" do rex_open --args "$(/usr/bin/jq -nc --arg cwd "$cwd" '{cwd: $cwd, files: $ARGS.positional}' --args "$@")"
