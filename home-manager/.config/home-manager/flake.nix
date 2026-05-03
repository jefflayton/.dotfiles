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
    television = {
      url = "github:alexpasmantier/television";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-bat-0_26_0.url = "github:nixos/nixpkgs/944fb34f0ba1975418248b9d45f901644a2b0743";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-bat-0_26_0,
      home-manager,
      claude-code-overlay,
      neovim-nightly-overlay,
      zig-overlay,
      television,
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
      pkgs-bat = import nixpkgs-bat-0_26_0 { inherit system; };
    in
    {
      homeConfigurations."jeffreylayton" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit television system; bat = pkgs-bat.bat; };
      };
    };
}
