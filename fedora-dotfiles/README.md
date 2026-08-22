# fedora-dotfiles

Dotfiles and a repeatable setup for a Fedora Workstation machine that dual boots
with Windows. Clone it, run one script, get the tools and the configuration.

Built from a macOS Homebrew list (`homebrew_packages.txt`), so it aims to give
the same working environment on Fedora.

## Quick start

```sh
sudo dnf install -y git stow
git clone https://github.com/<your-user>/fedora-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

Log out and back in when it finishes. That applies the new login shell and the
new `PATH`.

## Other ways to run it

```sh
./bootstrap.sh --list        # show the stages
./bootstrap.sh 20 80         # run only stage 20 and stage 80
DRY_RUN=1 ./bootstrap.sh     # show the plan, change nothing
INSTALL_DOCKER=1 ./bootstrap.sh 10   # also add the Docker CE repo
```

Every stage is safe to run again. Each one checks before it acts.

## Layout

```
bootstrap.sh          entry point, runs the stages in order
lib/common.sh         shared helpers: logging, list parsing, sudo
install/
  10-repos.sh         RPM Fusion, Flathub, VS Code, Chrome, COPR
  20-dnf.sh           all DNF packages
  30-flatpak.sh       all Flatpak applications
  40-toolchains.sh    rustup, fnm, uv, deno, ollama, starship
  50-language-packages.sh   cargo, npm, pipx and go tools
  60-fonts.sh         Nerd Fonts
  70-shell.sh         makes zsh the login shell
  80-stow.sh          links the dotfiles into $HOME
packages/
  dnf.txt             Fedora packages
  dnf-rpmfusion.txt   packages that need RPM Fusion
  copr.txt            COPR repos and their packages
  flatpak.txt         Flathub application IDs
  cargo.txt           Rust crates
  npm.txt             global npm packages
  pipx.txt            Python CLI tools
  go.txt              Go tools
  NOTES.md            Homebrew to Fedora mapping and manual steps
stow/                 one folder per tool, mirrors $HOME
```

## How to add a tool later

This is the part that is meant to grow.

1. **A Fedora package.** Add the name to `packages/dnf.txt`, then run
   `./bootstrap.sh 20`.
2. **A Flatpak app.** Find the ID with `flatpak search <name>`, add it to
   `packages/flatpak.txt`, then run `./bootstrap.sh 30`.
3. **A Rust, npm, Python or Go tool.** Add it to the matching file in
   `packages/`, then run `./bootstrap.sh 50`.
4. **A COPR package.** Add a line `owner/project package` to `packages/copr.txt`,
   then run `./bootstrap.sh 10 20`.
5. **A tool with its own installer.** Add a short block to
   `install/40-toolchains.sh`. Copy the shape of the blocks that are there:
   check first, then install, then report.

Then commit and push. The next machine gets it automatically.

## How to add a config file later

1. Make a folder under `stow/` named after the tool, for example `stow/bat`.
2. Inside it, copy the path as it sits in your home folder. For
   `~/.config/bat/config`, that is `stow/bat/.config/bat/config`.
3. Run `./bootstrap.sh 80`.

Stow makes the symlinks. Any real file that is in the way is moved to
`~/.dotfiles-backup/<timestamp>/` first, so nothing is lost.

## What is configured

| Tool | File |
|---|---|
| zsh | `stow/zsh/.zshrc`, `stow/zsh/.zshenv` |
| git | `stow/git/.gitconfig`, `stow/git/.config/git/ignore` |
| tmux | `stow/tmux/.config/tmux/tmux.conf` |
| neovim | `stow/nvim/.config/nvim/init.lua` |
| ghostty | `stow/ghostty/.config/ghostty/config` |
| starship | `stow/starship/.config/starship.toml` |

Machine-specific settings go in `~/.zshrc.local`. That file is not tracked, so
each machine can differ.

Set your git identity once per machine:

```sh
git config --global user.name  "Michael D'Annunzio"
git config --global user.email "you@example.com"
```

## When a package is missing

The installer never stops on a bad package name. It tests each name first,
skips the ones it cannot find, and writes them to:

```
~/.local/state/fedora-dotfiles/missing-packages.log
```

The log gives the manager, the name and the reason. Correct the name in the
matching file under `packages/`, then run the stage again.

## Known gaps

Some macOS applications have no Linux build. `packages/NOTES.md` lists them with
suggested replacements, plus the tools that need a manual download (Cursor,
Warp, NordVPN, Fing).

## Dual boot notes

Fedora and Windows keep different ideas about the hardware clock. If the Windows
clock is wrong after you boot Fedora, tell Fedora to use local time:

```sh
sudo timedatectl set-local-rtc 1 --adjust-system-clock
```

If you want to read the Windows partition from Fedora, install `ntfs-3g`. Turn
off Windows Fast Startup first, or the partition mounts read-only.

## Publish it to GitHub

```sh
cd ~/.dotfiles
git init -b main
git add .
git commit -m "Initial Fedora dotfiles"
gh repo create fedora-dotfiles --private --source=. --push
```

Without the `gh` CLI, create an empty repository on GitHub first, then:

```sh
git remote add origin git@github.com:<your-user>/fedora-dotfiles.git
git push -u origin main
```

## Licence

Personal configuration. Use any part of it.
