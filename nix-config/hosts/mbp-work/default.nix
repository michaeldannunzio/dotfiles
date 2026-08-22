# Work MacBook. Same core, different apps, no personal Homebrew list.
{ pkgs, username, fullName, email, ... }:
{
  imports = [
    ../../modules/darwin/defaults.nix
  ];

  networking.hostName = "mbp-work";
  networking.computerName = "mbp-work";

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  system.stateVersion = 6;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.pam.services.sudo_local.touchIdAuth = true;
  programs.zsh.enable = true;

  # Work only tools live here, not in the shared modules.
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "slack"
      "zoom"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit username fullName email; };
  home-manager.users.${username} = import ../../home/darwin.nix;
}
