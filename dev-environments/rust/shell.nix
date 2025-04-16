# A simple Rust development environment
# This can be used with `nix-shell` or `nix develop`

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Under the protection of Ferrus, Guardian of Memory Safety:
  buildInputs = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    
    # Build dependencies
    pkg-config
    openssl.dev
    
    # Additional tools
    cargo-edit  # For cargo add, cargo rm, etc.
    cargo-watch # For auto-reloading during development
  ];
  
  shellHook = ''
    # Create a new Rust project if Cargo.toml doesn't exist
    if [ ! -f Cargo.toml ]; then
      echo "Initializing Rust project..."
      cargo init --name my-project
    fi
    
    # Set up environment variables
    export RUST_BACKTRACE=1
    
    echo "Rust development environment activated with the protection of Ferrus, Guardian of Memory Safety!"
    echo "Rust version: $(rustc --version)"
    echo ""
    echo "Available commands:"
    echo "  - cargo build: Build the project"
    echo "  - cargo run: Run the project"
    echo "  - cargo test: Run tests"
    echo "  - cargo watch -x run: Auto-reload on changes"
    echo "  - cargo add <crate>: Add a dependency"
  '';
}
