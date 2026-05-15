{
  description = "My collection of utility scripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;
    
    removeShabang = str: if lib.strings.hasPrefix "#!" str then removeShabang (lib.strings.concatLines (lib.lists.drop 1 (lib.strings.splitString "\n" str))) else str;
  in { packages = rec {
    default = pkgs.symlinkJoin {
      name = "rc14s-utility-scripts";
      paths = [
        connectionTest
        selectDir
        u-nix
      ];
    };
    
    connectionTest = pkgs.writeShellApplication {
      name = "connectionTest";
      text = removeShabang (builtins.readFile ./connectionTest);
    };
    selectDir = pkgs.writeShellApplication {
      name = "selectDir";
      text = removeShabang (builtins.readFile ./selectDir);
      runtimeInputs = with pkgs; [
        fzf
        ripgrep
      ];
    };
    u-nix = pkgs.writeShellApplication {
      name = "u-nix";
      text = removeShabang (builtins.readFile ./u-nix);
      # Intentionally commented out to make it use the system nix in case the user uses determinate nix.
      # runtimeInputs = with pkgs; [
      #   nix
      # ];
    };
  }; });
}
