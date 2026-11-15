function localpkg --description 'Install packages on this machine only (mise config.local.toml)'
    # localpkg [-n] NAME…   bare NAME = brew:NAME; prefix anything else (brew-cask:ghostty)
    if not set -q argv[1]
        echo 'usage: localpkg [-n] NAME|manager:NAME…   (bare NAME = brew:NAME)' >&2
        return 2
    end
    set -l args
    for a in $argv
        if string match -q -- '-*' $a; or string match -q -- '*:*' $a
            set -a args $a
        else
            set -a args brew:$a
        end
    end
    mise bootstrap packages use -p ~/.config/mise/config.local.toml $args
end
