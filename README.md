# dotfiles

Machine configuration for every box I use, in one repository. Each top-level
directory is a self-contained layer with its own runbook; nothing outside a
directory depends on what is inside it.

| Directory | Manages | Tooling |
| --- | --- | --- |
| [`nix-config/`](nix-config/) | macOS hosts, a NixOS desktop, remote servers, and the WSL2 side of the PC | Nix flake, nix-darwin, home-manager |
| [`windows-config/`](windows-config/) | The Windows host: apps, registry settings, PowerShell, Terminal, WSL2 install | WinGet Configuration (DSC), PowerShell |
| [`fedora-dotfiles/`](fedora-dotfiles/) | Fedora Workstation on the dual-boot desktop | `bootstrap.sh`, GNU Stow, DNF/Flatpak |

Full setup instructions live with each layer:

- `nix-config/docs/SETUP-GUIDE.html`
- `windows-config/docs/SETUP-GUIDE.html`
- `fedora-dotfiles/README.md`

## How the layers fit together

Nix does not run natively on Windows, so the PC is managed by two layers rather
than one. `windows-config/` handles everything at and below the operating
system; the `homeConfigurations."server"` output in `nix-config/flake.nix` runs
inside WSL2 and gives the same shell, git, neovim, direnv and aliases as the
MacBook. Fedora is managed separately by `fedora-dotfiles/`.

```
                      nix-config/
      ┌──────────────┬──────┴───────┬──────────────┐
      │              │              │              │
 mbp-personal    mbp-work     linux-desktop    server ──► WSL2 on the PC
  (darwin)       (darwin)        (nixos)      (home-manager)

                    windows-config/  ──► the Windows host itself
                   fedora-dotfiles/  ──► Fedora on the dual-boot desktop
```

## Before you use any of it

Every layer ships with placeholders that must be filled in first:

- `nix-config/flake.nix` — `username`, `fullName`, `email` are all `CHANGE_ME`.
- `windows-config/dotfiles/gitconfig` and `.../ssh-config` — `CHANGE ME` /
  `CHANGE_ME`.
- `windows-config/dotfiles/windows-terminal-settings.json` — `CHANGE_ME` in the
  WSL profile path.
- `windows-config/wsl/wsl-bootstrap.sh` — `NIX_CONFIG_REPO` points at
  `CHANGE_ME`.
- `fedora-dotfiles/` — see its README.

No private keys or secrets are tracked here. The `.gitignore` files at the root
and in each layer block key material; `nix-config` carries a `sops-nix` input
for when secrets are actually needed.

## Provenance

These files were assembled from three Google Drive folders (`dotfiles`,
`Fedora dotfiles`, `Windows dotfiles`). Drive stores files flat, so the
directory trees were reconstructed from the layout blocks in each setup guide
and from the `Repo path:` header comment carried in most files.

Two points worth knowing:

- The Nix files existed in Drive in two revisions. The newer one (uploaded
  2026-08-22) uses directory-based hosts — `hosts/<name>/default.nix` — and its
  relative imports (`../../modules/...`) confirm it. That revision is what this
  repository uses. The older flat revision differed only in those import paths
  and in a `# Repo path:` header comment.
- Because no matching top-level `flake.nix` was uploaded with that newer
  revision, the module paths in `flake.nix` were changed from
  `./hosts/<name>.nix` to `./hosts/<name>` so they resolve against the
  directory layout. That is the only edit made to any file's logic.
