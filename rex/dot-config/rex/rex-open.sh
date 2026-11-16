#!/bin/sh
# Rex Open: open files in nvim in a new Rex tab, starting in the first file's folder.
#   rex-open.sh FILE...         (what "Rex Open.app" runs) shows a session picker
#                               as a floating pane in the session the app is showing.
#   rex-open.sh --pick SESSION FILE...   the picker itself, run inside that pane.
set -eu

rex="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
jq=/usr/bin/jq # GUI apps don't get the shell's PATH

if [ $# -eq 0 ]; then
  exec open -b com.superlogical.rex
fi

if [ "$1" != --pick ]; then
  # Rex can't tell which session the app is showing, so float a picker in every session's
  # current tab; whichever you're looking at shows it, and finishing one closes the rest.
  pickers=""
  for s in $("$rex" ls --json | $jq -r '.sessions[].session_id'); do
    cmd=$($jq -nc --arg sh "$0" --arg s "$s" '$ARGS.positional as $f | ["/bin/sh", $sh, "--pick", $s] + $f' --args "$@")
    b=$("$rex" api call -s "$s" session.new_layer "$($jq -nc --argjson cmd "$cmd" '{
      bounds: [0.25, 0.2, 0.5, 0.5], focus: true,
      layout: {block: {flavor: "com.superlogical.terminal.shell", label: "rex-open", options: {command: $cmd}}}}')" |
      $jq -r '.block_ids[0]') || continue # a session with no tabs can't hold one
    pickers="$pickers $s=$b"
  done
  open -b com.superlogical.rex
  # Coming to the front, the app puts focus back on the pane it had in the session it shows.
  sleep 0.5
  for p in $pickers; do
    "$rex" api call -s "${p%%=*}" session.focus_block "{\"block_id\":\"${p#*=}\"}" >/dev/null || true
  done
  exit 0
fi

# --- picker, running in a floating pane ---
current=$2
shift 2
close_others() { # every other picker; this one closes when the script exits
  for s in $("$rex" ls --json | $jq -r '.sessions[].session_id'); do
    "$rex" api call -s "$s" session.view '{}' | $jq -r --arg me "${REX_BLOCK:-}" '.windows[].layers[]?
      | select(any(.blocks[]?; .label == "rex-open") and all(.blocks[]?; .block_id != $me)) | .layer_id' |
      while read -r layer; do "$rex" api call -s "$s" session.close_layer "{\"layer_id\":\"$layer\"}" >/dev/null || true; done
  done
}
trap close_others EXIT
first=${1%/}
if [ -d "$first" ]; then cwd=$first; else cwd=$(dirname -- "$first"); fi
tab=$(basename -- "$first")
new="+ New session…"

# Lines are "ID<TAB>label"; the session you were looking at comes first.
choice=$(
  {
    "$rex" ls --json | $jq -r --arg c "$current" '.sessions | (map(select(.session_id == $c)) + map(select(.session_id != $c)))[] | "\(.session_id)\t\(.label)"'
    printf 'new\t%s\n' "$new"
  } | fzf --delimiter='\t' --with-nth=2 --reverse --no-sort --prompt="Open $tab in > "
) || exit 0
sid=${choice%%"	"*}

if [ "$sid" = new ]; then
  default=$(basename -- "$cwd")
  printf 'Session name [%s]: ' "$default"
  read -r name || exit 0
  r=$("$rex" new "${name:-$default}" -c "$cwd" --window "$tab" --json -- nvim -- "$@")
  sid=$(printf '%s' "$r" | $jq -r .session_id)
  wid=$(printf '%s' "$r" | $jq -r '.initial_windows[0].window_id')
else
  wid=$("$rex" window new -s "$sid" "$tab" -c "$cwd" --json -- nvim -- "$@" | $jq -r .window_id)
fi
"$rex" do session.select session_id="$sid" window_id="$wid"
