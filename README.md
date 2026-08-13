# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow
package whose contents mirror `$HOME`.

## Layout

- `tmux/.tmux.conf` — tmux config (Catppuccin Macchiato theme via TPM)
- `nvim/.config/nvim/` — LazyVim config
- `bash/.bashrc`, `bash/.bash_aliases`, `bash/.bash_profile`, `bash/.bash_logout` — bash config
- `claude/.claude/` — Claude Code global config: `CLAUDE.md`, `settings.json`, `statusline.sh`, and custom
  `skills/`. Deliberately excludes `.credentials.json`, `history.jsonl`, `projects/`, and other
  machine-local/session state, which are never checked in.

## Setup on a new machine

```sh
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
stow tmux nvim bash claude
```

This symlinks each package's files into place (e.g. `~/.tmux.conf`, `~/.config/nvim`).

## Adding a new package

```sh
mkdir -p ~/dotfiles/<name>
# move the real file/dir in, mirroring its path under $HOME
mv ~/.somerc ~/dotfiles/<name>/.somerc
cd ~/dotfiles && stow <name>
```

## Removing a package's symlinks

```sh
cd ~/dotfiles && stow -D <name>
```
