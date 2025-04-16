# A simple Node.js development environment
# This can be used with `nix-shell` or `nix develop`

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # By the wisdom of Nodeus, the Asynchronous One:
  buildInputs = with pkgs; [
    # Node.js and package managers
    nodejs_20
    yarn
    
    # Development tools
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.prettier
    nodePackages.typescript-language-server
  ];
  
  shellHook = ''
    # Set up environment variables
    export NODE_ENV=development
    
    # Create package.json if it doesn't exist
    if [ ! -f package.json ]; then
      echo "Initializing Node.js project..."
      yarn init -y
    fi
    
    echo "Node.js development environment activated by the blessing of Nodeus, the Asynchronous One!"
    echo "Node version: $(node --version)"
    echo "Yarn version: $(yarn --version)"
    echo ""
    echo "Available commands:"
    echo "  - yarn add <package>: Add a dependency"
    echo "  - yarn add -D <package>: Add a dev dependency"
    echo "  - yarn install: Install dependencies"
    echo "  - yarn start: Run the start script"
  '';
}
