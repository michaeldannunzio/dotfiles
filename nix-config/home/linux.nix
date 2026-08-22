# User configuration for Linux desktops and remote servers.
{ pkgs, username, ... }:
{
  imports = [ ./core.nix ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    # Linux only CLI tools go here.
    lsof
    strace
  ];

  # Needed for the standalone server build. It is harmless on NixOS.
  programs.home-manager.enable = true;
}
