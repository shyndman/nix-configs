# Simple Nix Project Example

This is a simple example project that demonstrates how to use Nix for:

1. Creating a reproducible development environment
2. Packaging a simple application
3. Making the application runnable

## Getting Started

Make sure you have Nix installed with flakes enabled.

### Development Environment

To enter the development environment:

```bash
# Enter the development shell
nix develop
```

### Building the Package

To build the package:

```bash
# Build the package
nix build
```

This will create a `result` symlink pointing to the built package.

### Running the Application

To run the application:

```bash
# Run the application
nix run
```

Or after building:

```bash
# Run the built application
./result/bin/simple-project
```

## Project Structure

- `flake.nix`: The Nix flake configuration
- `main.py`: A simple Python script that gets packaged

## Learning More

This is just a simple example. Nix can do much more, including:

- Defining complex build processes
- Creating reproducible environments across different machines
- Packaging applications for distribution
- Managing system configurations

Check out the [Nix documentation](https://nixos.org/learn.html) to learn more.
