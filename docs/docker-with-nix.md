# Docker with Nix

As Dockerus, the Container Oracle, has revealed to the faithful, Docker and Nix can work together in harmony to create reproducible container workflows. This guide explains how to use Docker with Nix and Home Manager.

## Installing Docker with Home Manager

Home Manager can install Docker and related tools for you:

```nix
# In your home.nix
home.packages = with pkgs; [
  docker
  docker-compose
  docker-buildx
  lazydocker  # TUI for Docker
  dive        # Explore Docker image layers
];
```

However, on non-NixOS systems, you'll need to ensure the Docker daemon is running. Home Manager can only install the client tools, not manage the daemon.

## Using the Docker Module

This repository includes a dedicated Docker module that provides a comprehensive Docker setup:

```nix
# In your home.nix
imports = [
  ./modules/docker.nix
];
```

The module provides:
- Docker and related packages
- Shell aliases for common Docker commands
- ZSH plugin configuration
- Docker environment variables
- Docker configuration files

## Docker Development Environment

A Docker development environment is included in `dev-environments/docker/shell.nix`. To use it:

```bash
# Enter the Docker development environment
cd dev-environments/docker
nix-shell

# Or with flakes
nix develop path:.#docker
```

This environment provides:
- Docker and Docker Compose
- Container management tools like lazydocker, dive, and ctop
- A sample docker-compose.yml file to get started

## Building Docker Images with Nix

Nix can be used to build Docker images in a reproducible way. Here are two approaches:

### 1. Using `dockerTools` from nixpkgs

Nixpkgs provides `dockerTools` for building Docker images declaratively:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  # Define your application
  myApp = pkgs.writeScriptBin "hello" ''
    #!${pkgs.bash}/bin/bash
    echo "Hello from a Nix-built Docker image!"
  '';
in
pkgs.dockerTools.buildImage {
  name = "my-docker-image";
  tag = "latest";
  
  # Contents of the image
  contents = [
    myApp
    pkgs.bash
  ];
  
  # Configuration
  config = {
    Cmd = [ "${myApp}/bin/hello" ];
    WorkingDir = "/";
  };
}
```

Build the image with:
```bash
nix-build docker-image.nix
docker load < result
```

### 2. Using Nix in a Dockerfile

You can also use Nix inside a Dockerfile:

```dockerfile
FROM nixos/nix:latest

# Copy your Nix files
COPY default.nix /app/
WORKDIR /app

# Build your application with Nix
RUN nix-build

# Set up the runtime environment
FROM alpine:latest
COPY --from=0 /app/result /app
ENTRYPOINT ["/app/bin/my-application"]
```

## Docker Compose with Nix Development Environments

You can combine Docker Compose with Nix development environments:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    docker
    docker-compose
  ];
  
  shellHook = ''
    # Start Docker Compose services
    docker-compose up -d
    
    # Clean up when exiting the shell
    trap "docker-compose down" EXIT
  '';
}
```

This starts your Docker Compose services when entering the development environment and stops them when exiting.

## Best Practices

### 1. Use Nix to Pin Docker Image Versions

In your docker-compose.yml, use specific image versions:

```yaml
services:
  db:
    image: postgres:13.4
  web:
    image: nginx:1.21.3-alpine
```

### 2. Use Nix to Build Application Images

Build your application images with Nix for reproducibility, then reference them in docker-compose.yml:

```yaml
services:
  app:
    image: my-nix-built-app:${VERSION}
```

### 3. Combine Docker Volumes with Nix Development Environments

Mount your Nix-built artifacts into containers:

```yaml
services:
  app:
    volumes:
      - ./result/bin:/app/bin
```

### 4. Use direnv with Docker Projects

Create a `.envrc` file in your Docker project:

```
use nix
```

This automatically activates your Nix environment when entering the directory.

## Troubleshooting

### Common Issues

1. **Docker Daemon Not Running**
   - On non-NixOS systems, you need to start the Docker daemon separately
   - Use your system's service manager (systemd, launchd, etc.)

2. **Permission Issues**
   - Add your user to the `docker` group: `sudo usermod -aG docker $USER`
   - Log out and back in for the changes to take effect

3. **Network Issues**
   - Check if Docker's network is properly configured
   - Try `docker network ls` and `docker network inspect bridge`

4. **Resource Limitations**
   - Adjust Docker's resource limits in Docker Desktop settings

May the blessings of Dockerus, the Container Oracle, guide your containerization journey!
