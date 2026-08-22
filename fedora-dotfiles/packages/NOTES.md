# Notes on the macOS to Fedora move

The source list is `homebrew_packages.txt`. Most Homebrew formulae in that file
are **library dependencies**, not tools you use directly. Examples: `boost`,
`brotli`, `cairo`, `folly`, `harfbuzz`, `icu4c`, `openssl@3`, `pcre2`, `zlib`.
Fedora pulls these in automatically as RPM dependencies, so they are not listed
in `dnf.txt`. Add a `-devel` package only when a build asks for a header.

## Direct replacements

| Homebrew | Fedora |
|---|---|
| `bat`, `eza`, `fzf`, `jq`, `ripgrep`, `btop`, `htop`, `tmux`, `neovim`, `tree` | same names in the Fedora repos |
| `gnupg` | `gnupg2` |
| `fd` | `fd-find` (binary is `fd`) |
| `vim` | `vim-enhanced` |
| `openjdk` | `java-latest-openjdk-devel` |
| `go` | `golang` |
| `llvm`, `llvm@22` | `llvm`, `clang`, `lld` |
| `mactex` | `texlive-scheme-medium` (large; add to `dnf.txt` if you want it) |
| `wireshark` | `wireshark-cli` plus the `org.wireshark.Wireshark` Flatpak |
| `docker-desktop` | `podman` and `podman-compose` by default. Set `INSTALL_DOCKER=1` for Docker CE. |
| `python@3.11` / `@3.13` / `@3.14` | system `python3` plus `uv` for extra versions (`uv python install 3.11`) |
| `rust` | `rustup` (installed by stage 40) |
| `node`, `fnm` | `nodejs` plus `fnm` (stage 40) |
| `tlrc` | `cargo install tlrc` |
| `prettyping` | `ping` with `-O`, or `gping` from `cargo` |
| `git-credential-manager` | Fedora uses `libsecret`: `git config --global credential.helper libsecret` |
| `onedrive` cask | `sudo dnf install onedrive` (the abraunegg CLI client) |
| `google-drive` cask | No official Linux client. Use `rclone` or GNOME Online Accounts. |

## No Linux build exists

These are macOS only. Suggested replacements are in the right column.

| macOS app | On Fedora |
|---|---|
| `alt-tab` | GNOME already does window switching; see the Alt Tab Workspace extension |
| `bartender`, `istat-menus` | GNOME extensions (Vitals, Tray Icons Reloaded) |
| `cleanmymac` | `ncdu`, `dnf autoremove`, `flatpak uninstall --unused` |
| `raycast` | `ulauncher` or `albert` |
| `iterm2` | `ghostty` (already in `copr.txt`) |
| `mas`, `duti`, `tag` | not applicable; use `xdg-mime` for default apps |
| `affinity` | no Linux build; GIMP, Krita or Inkscape |
| `wispr-flow` | no Linux build |
| `cork` | not applicable |
| `home-assistant` (companion app) | use the web interface |
| `chatgpt`, `canva` | web interfaces, or install as a web app from the browser |

## Needs a manual step

| Tool | How |
|---|---|
| Cursor | Anysphere ships an RPM and an AppImage. See <https://cursor.com/downloads>. An official DNF repo also exists; check the download page for the current URL. |
| Warp terminal | Download the x64 `.rpm` from <https://www.warp.dev/download> and run `sudo dnf install ./warp-terminal-*.rpm`. That RPM adds the Warp yum repo, so later updates come through `dnf`. |
| Claude desktop app | Check <https://claude.com/download> for a current Linux build before you add it. `@anthropic-ai/claude-code` (in `npm.txt`) is the CLI and works on Linux today. |
| NordVPN | `sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)` |
| `opencode` | Package name on npm was not confirmed. Check <https://opencode.ai> and add the correct name to `npm.txt`. |
| `merve` | Source not identified from the Homebrew name. Confirm what it is before you add it. |
| `balenaEtcher` | Flathub ID was not confirmed. Search with `flatpak search etcher` and add the ID to `flatpak.txt`. |
| `fing` | Download the Fedora build from <https://www.fing.com/products/development-toolkit>. |

Anything the installer cannot find is written to
`~/.local/state/fedora-dotfiles/missing-packages.log`, with the manager and the
reason. That file is the to-do list for the next pass.
