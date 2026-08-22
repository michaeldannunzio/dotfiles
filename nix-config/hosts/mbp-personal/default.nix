# Personal MacBook Pro M2. This is the primary machine.
{ pkgs, username, fullName, email, ... }:
{
  imports = [
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/homebrew.nix
  ];

  networking.hostName = "mbp-personal";
  networking.computerName = "mbp-personal";

  # Apple Silicon.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Recent nix-darwin needs this for user level options.
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # Do not change this after the first build.
  system.stateVersion = 6;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # If you install Determinate Nix instead of upstream Nix or Lix,
  # remove the comment marker below. Determinate manages the daemon itself.
  # nix.enable = false;

  # Touch ID for sudo. It survives a rebuild.
  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [ git vim ];

  # Wire home-manager into this host.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit username fullName email; };
  home-manager.users.${username} = import ../../home/darwin.nix;
}
