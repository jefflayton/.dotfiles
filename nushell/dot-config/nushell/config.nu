$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "nvim"

# Run a fish alias or function with these arguments. --no-config skips
# config.fish (slow, and nu already has its environment), so load just the
# aliases and the functions dir: about 10ms per call.
def --wrapped fish-run [name: string, ...args] {
  ^fish --no-config -c $"set -p fish_function_path ~/.config/fish/functions; source ~/.config/fish/aliases.fish; ($name) $argv" -- ...$args
}

# nvim, then cd to its last working directory (written on exit by nvim
# plugin/41_files.lua). Native, because a fish subprocess can't cd for nu.
def --env --wrapped nvim [...args] {
  let f = (mktemp -t nvim-cwd.XXXXXX)
  with-env {NVIM_CWD_FILE: $f} { ^nvim ...$args }
  let dir = (open --raw $f | str trim)
  rm -f $f
  if $dir != "" and $dir != $env.PWD { cd $dir }
}

# Machine-only settings in local.nu (gitignored); a missing file is fine.
const local = if ($nu.default-config-dir | path join "local.nu" | path exists) { $nu.default-config-dir | path join "local.nu" } else { null }
source $local
