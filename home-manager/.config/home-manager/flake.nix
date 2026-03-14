{
  description = "Home Manager configuration of jeffreylayton";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      claude-code-overlay,
      neovim-nightly-overlay,
      zig-overlay,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude" ];
        overlays = [
          claude-code-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          zig-overlay.overlays.default
        ];
      };
    in
    {
      homeConfigurations."jeffreylayton" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
