{
  description = "Multi-host Nix configuration: macOS, Linux desktop, remote servers";

  inputs = {
    # nixos-26.05 works for darwin and linux, so one branch serves every host.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets. Keep it, even if you enable it later.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... } @ inputs:
    let
      # ---------------------------------------------------------------
      # EDIT THESE THREE LINES FIRST
      # ---------------------------------------------------------------
      username = "CHANGE_ME";
      fullName = "CHANGE ME";
      email = "changeme@example.com";

      userArgs = { inherit inputs username fullName email; };
    in
    {
      # -----------------------------------------------------------------
      # macOS hosts. Build with:
      #   sudo darwin-rebuild switch --flake .#mbp-personal
      # -----------------------------------------------------------------
      darwinConfigurations."mbp-personal" = nix-darwin.lib.darwinSystem {
        specialArgs = userArgs;
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/mbp-personal
        ];
      };

      darwinConfigurations."mbp-work" = nix-darwin.lib.darwinSystem {
        specialArgs = userArgs;
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/mbp-work
        ];
      };

      # -----------------------------------------------------------------
      # Linux desktop.
      # Generate hardware-configuration.nix on the machine first with:
      #   sudo nixos-generate-config --show-hardware-config \
      #     > hosts/linux-desktop/hardware-configuration.nix
      # Then remove the comment markers below.
      # -----------------------------------------------------------------
      # nixosConfigurations."linux-desktop" = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   specialArgs = userArgs;
      #   modules = [
      #     home-manager.nixosModules.home-manager
      #     ./hosts/linux-desktop
      #   ];
      # };

      # -----------------------------------------------------------------
      # Remote servers. No root needed. Build on the server with:
      #   nix run home-manager/release-26.05 -- switch --flake .#server
      # -----------------------------------------------------------------
      homeConfigurations."server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = userArgs;
        modules = [ ./home/linux.nix ];
      };
    };
}
