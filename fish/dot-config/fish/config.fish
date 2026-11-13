set -gx EDITOR nvim

## Vi Key Bindings
set -g fish_key_bindings fish_vi_key_bindings
fish_default_key_bindings -M insert
fish_vi_key_bindings --no-erase insert
bind -M insert -m default 'KJ' cancel repaint-mode
bind -M visual -m default 'KJ' cancel repaint-mode 

## Aliases
# Git
alias gs="git status"
alias gp="git push"
alias gfo="git fetch origin"
alias gpo="git pull origin"
alias gcb="git checkout -b"
alias gco="git checkout origin"
alias gc="git checkout"
alias gaa="git add ."
alias ga="git add"
alias gcam="git commit -a -m"
alias gcm="git commit -m"

# Jujutsu
alias js="jj status"
alias jd="jj describe"
alias jn="jj new"
alias jr="jj rebase"
alias jgp="jj git push"
alias jgf="jj git fetch"
alias jb="jj bookmark"

# Other
alias ngrokh="ngrok http --url=normally-flexible-spider.ngrok-free.app"
alias tw="typst watch --open '/Applications/Zen\ Browser.app/'"
alias pn="pnpm"
alias cat="bat"
alias pc="pre-commit"

# Ripgrep
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/.ripgreprc"

# ngrok has no fish completion (emits zsh) — omitted

# bat, used by delta 		
set --export BAT_CONFIG_DIR "$HOME/.config/bat"

## Zoxide
zoxide init fish | source

## Initialize Oh My Posh
oh-my-posh init fish --config "$HOME/.config/ohmyposh/config.json" | source

# Rust
source "$HOME/.cargo/env.fish"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Run Mise
env MISE_LOG_LEVEL=warn mise activate fish | source

# Android Studio
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
fish_add_path -U "$ANDROID_HOME/emulator"
fish_add_path -U "$ANDROID_HOME/platform-tools"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/jeffreylayton/.opam/opam-init/init.fish' && source '/Users/jeffreylayton/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
# Rex completion
rex completion fish | source

shifty hook fish | source
