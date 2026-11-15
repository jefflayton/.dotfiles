# Migrating from stow + Brewfile to `mise bootstrap`

Config: `mise/dot-config/mise/conf.d/bootstrap.toml`. Delete this file once the migration is done.

## This machine

Your existing stow links point at the same sources, so mise counts them as already applied. You don't need to unstow anything, except Claude's settings.

1. Make `~/.claude/settings.json` a real file. It's a stow link today, and its source moved to `claude/settings.json`, so the link is broken once this branch is checked out. mise merges into the file and can't edit through a link:
   ```sh
   cp -L ~/.claude/settings.json /tmp/claude-settings.json   # before checking out this branch
   rm ~/.claude/settings.json && mv /tmp/claude-settings.json ~/.claude/settings.json
   ```
1. Preview. This is read-only:
   ```sh
   cd ~ && mise dot status && mise bootstrap --dry-run
   ```
   Expected output: packages, tools and the login shell are already satisfied. Only `~/.config/{pitchfork,tmux,tuicr,yazi}` get new links if they were never stowed, and `~/.claude/settings.json` gets the shared keys merged in.
2. Apply:
   ```sh
   cd ~ && mise bootstrap
   ```
3. Retire stow and the Brewfile:
   ```sh
   rm ~/Brewfile          # stow link into brew/
   jj file untrack brew/ && rm -r brew/   # or keep it until you trust packages
   brew uninstall stow
   ```
4. Delete this file and commit.

## New machine

1. Install Homebrew, then `brew install mise git`.
2. `git clone <this repo> ~/dotfiles`. `dotfiles.root` expects this path.
3. Link mise's config by hand. This is the one bootstrap step mise can't do for itself:
   ```sh
   mkdir -p ~/.config && ln -s ~/dotfiles/mise/dot-config/mise ~/.config/mise
   ```
4. `cd ~ && mise bootstrap --dry-run`, then `mise bootstrap`. It runs packages, then dotfiles, then the login shell (fish), then tools.
5. Open a new login session so the shell change takes effect.

Untested shortcut for steps 2–3:
`mise bootstrap --from <url> --from-dir ~/dotfiles --config-dir mise/dot-config/mise`

## Day to day

| stow / brew                  | mise                                        |
| ---------------------------- | ------------------------------------------- |
| `stow <pkg>`                 | add a `[dotfile_groups.<pkg>]`, `mise dot apply` |
| `stow -D <pkg>`              | `mise dot unapply --group <pkg>`            |
| `brew bundle`                | `mise bootstrap packages apply`             |
| add to Brewfile              | `mise bootstrap packages use -g brew:<name>` |
| `brew bundle cleanup`        | `mise bootstrap packages prune --manager brew --dry-run` |
| see what differs             | `mise dot status`, `mise dot diff`, `mise bootstrap status` |

New package `foo` with config in `foo/dot-config/foo`: copy one of the `~/.config/<app>` group blocks and add `"foo"` to `[bootstrap] dotfile_groups`.

## Notes

- `~/.config/<app>` groups are whole-directory symlinks, the same as stow's folding. Files that apps generate land in the repo, and `.gitignore` keeps them out of git.
- `git` and `godot` link file by file (`manifest = "git"`), so only tracked files are deployed.
- mise's history and sync features (`mode = "track"`, `mise dot origin`) are not used. They keep a separate bare repo, and this git/jj repo already covers that.

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
