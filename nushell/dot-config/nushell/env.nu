# nu is meant to run on top of fish (`nu` from a fish prompt, `exit` to go
# back), so it inherits fish's environment: PATH, EDITOR, RIPGREP_CONFIG_PATH...
#
# This file regenerates the integrations below into nu's autoload dir on every
# start. nu sources that dir after config.nu, so they never go stale.

let autoload = ($nu.user-autoload-dirs | first)
mkdir $autoload
def gen [name: string, script: string] {
  $script | save -f ($autoload | path join $"($name).nu")
}

gen mise (MISE_LOG_LEVEL=warn ^mise activate nu)
gen zoxide (^zoxide init nushell)
gen oh-my-posh (^oh-my-posh init nu --config ($env.HOME | path join ".config/ohmyposh/config.json") --print)

# Every fish alias (aliases.fish) and function (functions/*.fish) becomes a nu
# command that runs it in fish (`fish-run`, config.nu). Names nu already has
# as built-ins are skipped, and so is nvim, which config.nu defines natively.
let fish = ($env.HOME | path join ".config/fish")
let names = (
  (open --raw ($fish | path join "aliases.fish") | lines | parse --regex '^alias (?<name>[^=\s]+)=' | get name)
  ++ (glob ($fish | path join "functions/*.fish") | path parse | get stem)
)
let skip = ["nvim"] ++ (scope commands | where type in [built-in keyword plugin] | get name)
gen fish-bridge (
  $names | uniq
  | where {|n| not ($n | str starts-with "_") and not ($n | str starts-with "fish_") and $n not-in $skip }
  | each {|n| $"def --wrapped ($n) [...args] { fish-run ($n) ...$args }" }
  | str join "\n"
)
