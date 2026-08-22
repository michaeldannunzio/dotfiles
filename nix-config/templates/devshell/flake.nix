# Copy this file into each project. It replaces nvm, pyenv, and rustup.
# Keep only the section you need.
{
  description = "Project development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # --- Web: JS and TS ---
            nodejs
            pnpm

            # --- Python ---
            python3
            uv

            # --- Go ---
            go
            gopls

            # --- Rust ---
            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer
          ];

          shellHook = ''
            echo "dev shell ready"
          '';
        };
      });
}
