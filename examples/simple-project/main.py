#!/usr/bin/env python3

# A simple Python script packaged with Nix

def main():
    print("Hello from a Nix-packaged Python script!")
    print("May the blessings of Pythus, the Indentation Deity, be upon you!")
    
    # Print some information about the environment
    import sys
    print(f"Python version: {sys.version}")
    
    # Try to import some packages that should be available
    try:
        import numpy
        print(f"NumPy version: {numpy.__version__}")
    except ImportError:
        print("NumPy is not available")
    
    print("\nThis script is packaged using Nix, a purely functional package manager.")
    print("Learn more at https://nixos.org")

if __name__ == "__main__":
    main()
