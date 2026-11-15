# Aliases, shared with nushell: config.fish sources this file, and nu runs
# each alias through `fish --no-config` (see nushell/dot-config/nushell/env.nu).
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
