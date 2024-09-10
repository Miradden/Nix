{
  description = "Configuration flake";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # auto ricing
    stylix.url = "github:danth/stylix";

    # NVChad
    nvchad4nix = {
      url = "github:NvChad/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
 
#   outputs = { self, nixpkgs, home-manager, ... }@inputs:
#     let
#       system = "x86_64-linux";
#       extraSpecialArgs = { inherit system; inherit inputs; };  # <- passing inputs to the attribute set for home-manager
#       specialArgs = { inherit system; inherit inputs; };       # <- passing inputs to the attribute set for NixOS (optional)
#     in {
#     nixosConfigurations = {
#       pearlescent = nixpkgs.lib.nixosSystem {
#         modules = [
#           ./configuration.nix
#           {  # <- # example to add the overlay to Nixpkgs:
#             nixpkgs = {
#               overlays = [
#                 inputs.nvchad4nix.overlays.default
#               ];
#             };
#           }
          
#           # stylix theming
#           inputs.stylix.nixosModules.stylix
#           # hardware config for specifc device
#           inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
          
#           # home-manager.nixosModules.home-manager {
#           #   home-manager = {
#           #     inherit extraSpecialArgs;  # <- this will make inputs available anywhere in the HM configuration
#           #     useGlobalPkgs = true;
#           #     useUserPackages = true;
#           #   };
#           # }
#         ];
#       };
#     };

outputs = inputs@{ self, nixpkgs, home-manager, stylix, nixos-hardware, ... }: {
    nixosConfigurations = {
      pearlescent = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {system = "x86_64-linux"; inherit inputs; };
        modules = [
          ./configuration.nix

          {  # <- # example to add the overlay to Nixpkgs:
            nixpkgs = {
              overlays = [
                (final: prev: {
                    nvchad = inputs.nvchad4nix.packages.x86_64-linux.nvchad;
                })
              ];
            };
          }
          
          # stylix theming
          stylix.nixosModules.stylix
          
          # hardware config for specifc device
          nixos-hardware.nixosModules.asus-zephyrus-ga402
 
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mirad = import ./home.nix;
            home-manager.extraSpecialArgs = {inherit inputs; system = "x86_64-linux";};

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
