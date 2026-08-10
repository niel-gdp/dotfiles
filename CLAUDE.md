# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Daniel's personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a stow package whose contents mirror `$HOME` — e.g. `tmux/.tmux.conf` stows to `~/.tmux.conf`,
`nvim/.config/nvim/` stows to `~/.config/nvim/`. New files for a package must be added at the matching
path under that package directory, not directly under `$HOME`.

## Commands

Apply a package's symlinks into `$HOME`:
```sh
cd ~/dotfiles && stow tmux nvim bash
```

Remove a package's symlinks:
```sh
cd ~/dotfiles && stow -D <name>
```

Add a new package: create `~/dotfiles/<name>/`, move the real file/dir in mirroring its path under
`$HOME` (e.g. `~/dotfiles/<name>/.somerc`), then `stow <name>`.

There is no build/lint/test step for this repo itself; the packages configure other tools that have
their own (see below).

## Layout and architecture

- `tmux/.tmux.conf` — tmux config, Catppuccin Macchiato theme, plugins managed via TPM (`~/.tmux/plugins/`,
  not part of this repo). Reload with `tmux source-file ~/.tmux.conf` or prefix+`r`. Since `.tmux.conf` is
  a symlink from stow, edit the file through the symlink (or the repo path directly) — either works, they
  are the same inode.
  - Status bar right-hand modules are assembled by catppuccin's `status/*.conf` files, which set
    `@catppuccin_<module>_text` etc. with `set -ogq` (only-if-unset). Any override of those `@catppuccin_*`
    options must be set *before* TPM's `run '~/.tmux/plugins/tpm/tpm'` at the bottom of the file to win.
  - Async `#(...)` job output (used for kubectx context/namespace, CPU, RAM) only populates through the
    real attached client's status-line redraw loop (`status-interval`) — it cannot be verified with
    `tmux display-message -p` from a plain shell, which always shows the job as empty/unpopulated. Test
    such changes by watching the live status bar, not by querying the format via a one-off command.
  - tmux's `#{s/pattern/replacement/:string}` format modifier does not reliably resolve when `string` is
    itself an async `#(...)` job — prefer piping the job's shell command through `sed` instead (see the
    kubectx context override in this file for the working pattern).
- `nvim/.config/nvim/` — LazyVim-based Neovim config. Standard LazyVim layout: `lua/config/` for
  options/keymaps/autocmds/lazy bootstrap, `lua/plugins/` for plugin specs (one file per concern).
  `lua/plugins/devops.lua` is the notable custom addition: adds `bashls`, `shellcheck`, and `shfmt` for
  shell scripting, on top of whatever LazyVim extras are enabled in `lazyvim.json`.
- `bash/` — `.bashrc`, `.bash_aliases`, `.bash_profile`, `.bash_logout`.
