#!/bin/bash
# Claude Code statusline. Reads the JSON Claude Code pipes on stdin.
#
#   Opus 5.5                                     5h 25% 2h14m · 7d 19% 3d4h
#
# Left: model. Right: usage limits (used %, time to reset), right-aligned to
# $COLUMNS. When the line is too narrow, usage drops first.

export LC_ALL=en_US.UTF-8 # so ${#var} counts characters, not bytes

RIGHT_MARGIN=8 # columns Claude Code's statusline area is narrower than $COLUMNS

input=$(cat)
now=$(date +%s)
cols=${COLUMNS:-80}

esc=$'\033'
dim="$esc[2m"; reset="$esc[0m"
yellow="$esc[33m"; red="$esc[31m"

visible_len() { # length without ANSI escapes
  local s
  s=$(sed $'s/\033\\[[0-9;]*m//g' <<<"$1")
  printf '%d' "${#s}"
}

fmt_left() { # seconds -> 43m | 2h14m | 3d4h
  local s=$1
  ((s < 0)) && s=0
  if ((s < 3600)); then printf '%dm' $((s / 60))
  elif ((s < 86400)); then printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  else printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600))
  fi
}

# --- left: model ---------------------------------------------------------------
left=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")

# --- right: usage limits -----------------------------------------------------
right=""
while IFS=$'\t' read -r key pct resets; do
  [[ -z $key ]] && continue
  case $key in
    five_hour) label=5h ;;
    seven_day) label=7d ;;
    seven_day_*) label="7d ${key#seven_day_}" ;;
    *) label=$key ;;
  esac
  pct=${pct%.*}
  if ((pct >= 80)); then color=$red
  elif ((pct >= 50)); then color=$yellow
  else color=""
  fi
  seg="${label} ${color}${pct}%${reset}"
  [[ -n $resets && $resets != null ]] && seg+=" ${dim}$(fmt_left $((resets - now)))${reset}"
  right+="${right:+ ${dim}·${reset} }${seg}"
done < <(jq -r '.rate_limits // {} | to_entries[]
  | select(.value | type == "object" and .used_percentage != null)
  | [.key, .value.used_percentage, (.value.resets_at // "null")] | @tsv' <<<"$input")

# --- layout --------------------------------------------------------------------
width=$((cols - RIGHT_MARGIN))
llen=$(visible_len "$left")
rlen=$(visible_len "$right")
gap=$((width - llen - rlen))

if [[ -n $right ]] && ((gap >= 2)); then
  printf '%s%*s%s' "$left" "$gap" "" "$right"
else
  printf '%s' "$left" # too narrow (or no usage yet): drop usage
fi
