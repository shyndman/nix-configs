{
  description = "A simple project with Nix";

  # By the divine guidance of Flakeus, the Input Provider:
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Add your development dependencies here
            python311
            nodejs_20
          ];

          shellHook = ''
            echo "Welcome to the project development environment!"
            echo "May the blessings of Nixus be upon your code!"
          '';
        };
        
        # Package definition
        packages.default = pkgs.stdenv.mkDerivation {
          name = "simple-project";
          version = "0.1.0";
          src = ./.;

          buildInputs = with pkgs; [
            python311
          ];

          buildPhase = ''
            mkdir -p $out/bin
            cp ${./main.py} $out/bin/simple-project
            chmod +x $out/bin/simple-project
          '';

          installPhase = ''
            # Nothing to do here as we did everything in buildPhase
          '';
        };

        # App definition
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/simple-project";
        };
      }
    );
}
