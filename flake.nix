{
  description = "Nix configuration for packages and development environments";

  inputs = {
    # Blessed by Nixus, the Package Provider
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Systems supported
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported systems
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Home Manager configurations
      homeConfigurations = {
        "your-username" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.x86_64-linux; # Adjust for your system architecture
          modules = [
            ./home.nix
            # Uncomment to enable modules
            # ./modules/docker.nix
            # ./modules/python.nix
          ];
        };

        # Raspberry Pi 5 configuration for user vantron
        "vantron" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.aarch64-linux; # Raspberry Pi 5 uses aarch64 architecture
          modules = [
            ./home-pi5.nix
            # Modules are imported in home-pi5.nix
          ];
        };
      };

      # Development shells for different environments
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          # Python development environment
          python = pkgs.mkShell {
            buildInputs = with pkgs; [
              python311
              python311Packages.pip
              python311Packages.virtualenv
              python311Packages.black
              python311Packages.flake8
            ];
            shellHook = ''
              echo "Python development environment activated by the grace of Pythus, the Indentation Deity!"
              echo "Python version: $(python --version)"
            '';
          };

          # Node.js development environment
          node = pkgs.mkShell {
            buildInputs = with pkgs; [
              nodejs_20
              yarn
              nodePackages.typescript
              nodePackages.eslint
            ];
            shellHook = ''
              echo "Node.js development environment activated by the blessing of Nodeus, the Asynchronous One!"
              echo "Node version: $(node --version)"
              echo "Yarn version: $(yarn --version)"
            '';
          };

          # Rust development environment
          rust = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustc
              cargo
              rustfmt
              clippy
              rust-analyzer
            ];
            shellHook = ''
              echo "Rust development environment activated with the protection of Ferrus, Guardian of Memory Safety!"
              echo "Rust version: $(rustc --version)"
            '';
          };

          # Docker development environment
          docker = pkgs.mkShell {
            buildInputs = with pkgs; [
              docker
              docker-compose
              docker-buildx
              lazydocker
              dive
              ctop
            ];
            shellHook = ''
              echo "Docker development environment activated by the blessing of Dockerus, the Container Oracle!"
              echo "Docker version: $(docker --version)"
              echo "Docker Compose version: $(docker-compose --version)"
            '';
          };
        }
      );
    };
}
