# Migrating from stow + Brewfile to `mise bootstrap`

Config: `mise/dot-config/mise/conf.d/bootstrap.toml`. Delete this file once the migration is done.

## This machine

Your existing stow links point at the same sources, so mise counts them as already applied. You don't need to unstow anything.

1. Preview. This is read-only:
   ```sh
   cd ~ && mise dot status && mise bootstrap --dry-run
   ```
   Expected output: packages, tools and the login shell are already satisfied. Only `~/.config/{pitchfork,tmux,tuicr}` get new links, because they were never stowed.
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
