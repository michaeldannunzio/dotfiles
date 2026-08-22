# Linux desktop. STUB.
# Run this on the machine first, then enable the output in flake.nix:
#   sudo nixos-generate-config --show-hardware-config \
#     > hosts/linux-desktop/hardware-configuration.nix
{ pkgs, username, fullName, email, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "linux-desktop";
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "26.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit username fullName email; };
  home-manager.users.${username} = import ../../home/linux.nix;
}
