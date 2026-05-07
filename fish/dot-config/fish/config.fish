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
alias jr="jj rebase --onto"
alias jgp="jj git push --bookmark"
alias jgf="jj git fetch --bookmark"

# Other
alias ngrokh="ngrok http --url=normally-flexible-spider.ngrok-free.app"
alias typstw="typst watch --open '/Applications/Zen\ Browser.app/'"
alias pn="pnpm"

# Ripgrep
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/.ripgreprc"

# pnpm 		
set -gx PNPM_HOME "$HOME/Library/pnpm" 		
if not string match -q -- $PNPM_HOME $PATH 		
    set -gx PATH "$PNPM_HOME" $PATH 		
end

# Ngrok Completions 		
if command -v ngrok &>/dev/null 		
    eval "$(ngrok completion)" 		
end 		
    
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

# Add Direnv
mise activate fish | source
