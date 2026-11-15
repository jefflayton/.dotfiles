# dotfiles

Managed by `mise bootstrap`: dotfiles, Homebrew packages, the login shell and tools.
Config: `mise/dot-config/mise/conf.d/bootstrap.toml` (tools stay in `mise/dot-config/mise/config.toml`).

## New machine

1. Install Homebrew, then `brew install mise git`.
2. `git clone <this repo> ~/.dotfiles`. `dotfiles.root` expects this path.
3. Link mise's config by hand. This is the one bootstrap step mise can't do for itself:
   ```sh
   mkdir -p ~/.config && ln -s ~/.dotfiles/mise/dot-config/mise ~/.config/mise
   ```
4. `cd ~ && mise bootstrap --dry-run`, then `mise bootstrap`. It runs packages, then dotfiles, then the login shell (fish), then tools.
5. Open a new login session so the shell change takes effect.

Untested shortcut for steps 2–3:
`mise bootstrap --from <url> --from-dir ~/.dotfiles --config-dir mise/dot-config/mise`

## Machine still on stow at `~/dotfiles`

1. Unstow from the old folder, so no link points into it, and keep Claude's settings as a real file:
   ```sh
   cp -L ~/.claude/settings.json /tmp/claude-settings.json
   cd ~/dotfiles && stow --dotfiles -D $(ls -d */ | tr -d /) && cd ~
   mv /tmp/claude-settings.json ~/.claude/settings.json
   ```
2. `mv ~/dotfiles ~/.dotfiles`, pull, then continue from step 3 of **New machine**.
3. `brew uninstall stow`.

## Day to day

| Task | Command |
| ---- | ------- |
| new package `foo` with config in `foo/dot-config/foo` | copy a `~/.config/<app>` group block, add `"foo"` to `[bootstrap] dotfile_groups`, `mise dot apply` |
| remove a package's links | `mise dot unapply --group <pkg>` |
| install declared packages | `mise bootstrap packages apply` |
| add a Homebrew package | `mise bootstrap packages use -g brew:<name>` |
| find undeclared Homebrew packages | `mise bootstrap packages prune --manager brew --dry-run` |
| see what differs | `mise dot status`, `mise dot diff`, `mise bootstrap status` |

## Notes

- `~/.config/<app>` groups are whole-directory symlinks. Files that apps generate land in the repo, and `.gitignore` keeps them out of git.
- `git` and `godot` link file by file (`manifest = "git"`), so only tracked files are deployed.
- mise's history and sync features (`mode = "track"`, `mise dot origin`) are not used. They keep a separate bare repo, and this git/jj repo already covers that.
- `login_shell` is a full path (`/opt/homebrew/bin/fish`), which only fits Homebrew on Apple silicon.

## Machine-only config

Per-machine settings (work orgs, hosts, tokens) never go in this public repo. Each tool loads its own local file; every one of them is optional and gitignored by the `local.*`, `*.local`, `*.local.*` patterns. Files under `~/.config/<app>` sit inside this repo through the directory link, so the gitignore is what keeps them private.

| Tool | Local file |
| ---- | ---------- |
| git, delta | `~/.gitconfig.local` |
| jj | `~/.config/jj/conf.d/local.toml` (any `*.toml` there) |
| mise | `~/.config/mise/config.local.toml` |
| fish | `~/.config/fish/conf.d/local.fish` (any `*.fish` there) |
| ghostty | `~/.config/ghostty/config.local` |
| tmux | `~/.config/tmux/local.conf` |
| nvim | `~/.config/nvim/after/plugin/local.lua` (nvim runs it after the other plugin files) |
| rex | `~/.config/rex/local.lua` |
| Claude | edit `~/.claude/settings.json` directly. `mise dot apply` overwrites the keys in `claude/settings.json` (arrays such as `hooks` are replaced whole) and keeps every other key. |

bat, ripgrep, yazi and oh-my-posh have no include. If one needs to differ per machine, set it with env vars in `conf.d/local.fish`, or turn its file into a mise template or merge edit. A mise edit needs its group to be `symlink-each`, not `symlink`.

Keep a private copy of these files somewhere (they aren't in any repo).
