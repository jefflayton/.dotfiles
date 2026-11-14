function claude-send --description 'Continue a Claude Code session on another Rex host'
    # claude-send HOST REMOTE_DIR [SESSION_ID]
    #   Copies the session transcript to HOST through a Rex pane, then runs
    #   `claude --resume` there in REMOTE_DIR. Default session: the newest one
    #   for the current directory. Push your code changes first.
    if test (count $argv) -lt 2
        echo 'usage: claude-send HOST REMOTE_DIR [SESSION_ID]' >&2
        return 2
    end
    set -l host $argv[1]
    set -l remote_dir $argv[2]
    set -l cwd (pwd -P)
    set -l project ~/.claude/projects/(string replace -ra '[^A-Za-z0-9]' - -- $cwd)

    set -l file
    if set -q argv[3]
        set file $project/$argv[3].jsonl
    else
        set file (ls -t $project/*.jsonl 2>/dev/null)[1]
    end
    if not test -f "$file"
        echo "claude-send: no session found in $project" >&2
        return 1
    end
    set -l id (basename $file .jsonl)

    # Runs on HOST: wait for the gzipped base64 transcript on the terminal,
    # file it under REMOTE_DIR's project, point its cwd entries there, resume.
    set -l receive '
d=$1 id=$2 old=$3
case $d in "~"|"~/"*) d=$HOME${d#\~} ;; esac
cd "$d" || { echo "claude-send: no such directory: $d"; sleep 30; exit 1; }
new=$(pwd -P)
dir=$HOME/.claude/projects/$(printf %s "$new" | sed "s/[^A-Za-z0-9]/-/g")
mkdir -p "$dir"
stty -echo
echo CLAUDE_SEND_READY
awk "/^__END__\$/{exit} {print}" | base64 -d | gunzip | sed "s|\"cwd\":\"$old|\"cwd\":\"$new|g" > "$dir/$id.jsonl"
stty echo
exec claude --resume "$id"'

    set -l block (rex -S $host run --json --label claude-send -- /bin/sh -c $receive sh $remote_dir $id $cwd | jq -r '.block_id // .block_ids[0] // empty')
    if test -z "$block"
        echo "claude-send: could not open a pane on $host" >&2
        return 1
    end

    # Wait for the receiver before sending, so nothing is typed into the shell early.
    for i in (seq 50)
        rex -S $host capture -b $block 2>/dev/null | string match -q '*CLAUDE_SEND_READY*'; and break
        sleep 0.2
    end
    set -l payload (mktemp -d)
    begin
        gzip -c $file | base64 | fold -w 76 # short lines: tty line buffers are ~1KB
        echo __END__
    end >$payload/all
    split -b 60000 $payload/all $payload/part. # rex send caps one request at 64KB

    set -l ok (test $i -lt 50; and echo 1)
    if test -n "$ok"
        for part in $payload/part.*
            rex -S $host send -b $block <$part; or begin
                set ok
                break
            end
        end
    end
    rm -r $payload

    if test -z "$ok"
        echo "claude-send: transfer to $host failed; closing pane $block" >&2
        rex -S $host api call block.close "{\"block_id\":\"$block\"}" >/dev/null 2>&1
        return 1
    end
    echo "claude-send: session $id → $host:$remote_dir (pane $block)"
end
