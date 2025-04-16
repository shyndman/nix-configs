# Docker module for Home Manager
# This module configures Docker and related tools

{ config, pkgs, lib, ... }:

{
  # As Dockerus, the Container Oracle, has decreed:

  # Install Docker and related tools
  home.packages = with pkgs; [
    docker
    docker-compose
    docker-buildx
    lazydocker # TUI for Docker
    dive       # Explore Docker image layers
    ctop       # Container monitoring
    podman     # Alternative container runtime
    skopeo     # Container image management
  ];

  # Docker shell aliases
  programs.bash.shellAliases = {
    # Docker
    d = "docker";
    dc = "docker compose";
    dps = "docker ps";
    dpsa = "docker ps -a";
    di = "docker images";
    drmi = "docker rmi";
    drm = "docker rm";
    dex = "docker exec -it";
    drun = "docker run -it";
    dlogs = "docker logs -f";
    dprune = "docker system prune -af";

    # Docker Compose
    dcup = "docker compose up -d";
    dcdown = "docker compose down";
    dcrestart = "docker compose restart";
    dclogs = "docker compose logs -f";

    # Docker Stacks
    stack-new = "stack-init";
    stack-up = "cd ~/stacks/\$1 && docker compose up -d";
    stack-down = "cd ~/stacks/\$1 && docker compose down";
    stack-logs = "cd ~/stacks/\$1 && docker compose logs -f";
    stack-restart = "cd ~/stacks/\$1 && docker compose restart";
    stack-ps = "cd ~/stacks/\$1 && docker compose ps";
    stack-list = "ls -la ~/stacks";
  };

  # ZSH configuration for Docker
  programs.zsh.shellAliases = {
    # Docker
    d = "docker";
    dc = "docker compose";
    dps = "docker ps";
    dpsa = "docker ps -a";
    di = "docker images";
    drmi = "docker rmi";
    drm = "docker rm";
    dex = "docker exec -it";
    drun = "docker run -it";
    dlogs = "docker logs -f";
    dprune = "docker system prune -af";

    # Docker Compose
    dcup = "docker compose up -d";
    dcdown = "docker compose down";
    dcrestart = "docker compose restart";
    dclogs = "docker compose logs -f";

    # Docker Stacks
    stack-new = "stack-init";
    stack-up = "cd ~/stacks/\$1 && docker compose up -d";
    stack-down = "cd ~/stacks/\$1 && docker compose down";
    stack-logs = "cd ~/stacks/\$1 && docker compose logs -f";
    stack-restart = "cd ~/stacks/\$1 && docker compose restart";
    stack-ps = "cd ~/stacks/\$1 && docker compose ps";
    stack-list = "ls -la ~/stacks";
  };

  # Add Docker ZSH plugin if using Oh-My-Zsh
  programs.zsh.oh-my-zsh = lib.mkIf config.programs.zsh.oh-my-zsh.enable {
    plugins = [ "docker" "docker-compose" ];
  };

  # Docker environment variables
  home.sessionVariables = {
    DOCKER_BUILDKIT = "1";  # Enable BuildKit for faster builds
    COMPOSE_DOCKER_CLI_BUILD = "1";  # Use Docker CLI for builds in Compose
  };

  # Create Docker config directory and configuration
  home.file.".docker/config.json".text = builtins.toJSON {
    experimental = "enabled";
    features = {
      buildkit = true;
    };
  };

  # Create a directory structure for Docker stacks
  home.file."stacks/.gitkeep".text = "";

  # Create a template compose.yaml file
  home.file.".config/docker/templates/compose.yaml.template".text = ''
    # Docker Compose template blessed by Dockerus, the Container Oracle
    # Created for the stacks directory structure

    version: '3.8'

    services:
      app:
        image: your-image:latest
        container_name: ${"${STACK_NAME}"}-app
        restart: unless-stopped
        environment:
          - TZ=UTC
        volumes:
          - ./data:/data
        networks:
          - ${"${STACK_NAME}"}-network

    networks:
      ${"${STACK_NAME}"}-network:
        name: ${"${STACK_NAME}"}-network

    volumes:
      data:
        name: ${"${STACK_NAME}"}-data
  '';

  # Create a script to initialize new Docker stacks
  home.file.".local/bin/stack-init".executable = true;
  home.file.".local/bin/stack-init".text = ''
    #!/usr/bin/env bash

    # stack-init - A script to create new Docker stack directories
    # Blessed by Dockerus, the Container Oracle

    set -e

    function show_help {
      echo "stack-init - Create a new Docker stack directory"
      echo ""
      echo "Usage: stack-init <stack_name> [--template TEMPLATE]"
      echo ""
      echo "Templates:"
      echo "  basic     - Basic Docker Compose stack (default)"
      echo "  web       - Web application with reverse proxy"
      echo "  database  - Database with persistence"
      echo ""
      echo "Examples:"
      echo "  stack-init myapp"
      echo "  stack-init mydb --template database"
    }

    STACK_NAME=""
    TEMPLATE="basic"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
      case $1 in
        --template|-t)
          TEMPLATE="$2"
          shift 2
          ;;
        --help|-h)
          show_help
          exit 0
          ;;
        *)
          if [ -z "$STACK_NAME" ]; then
            STACK_NAME="$1"
          else
            echo "Error: Unknown argument $1"
            show_help
            exit 1
          fi
          shift
          ;;
      esac
    done

    if [ -z "$STACK_NAME" ]; then
      echo "Error: Stack name is required"
      show_help
      exit 1
    fi

    STACK_DIR="$HOME/stacks/$STACK_NAME"

    if [ -d "$STACK_DIR" ]; then
      echo "Error: Stack directory $STACK_DIR already exists"
      exit 1
    fi

    echo "Creating $TEMPLATE stack: $STACK_NAME"

    # Create stack directory
    mkdir -p "$STACK_DIR"
    cd "$STACK_DIR"

    # Create basic structure
    mkdir -p data config logs

    # Create compose.yaml based on template
    case "$TEMPLATE" in
      basic)
        export STACK_NAME
        envsubst < "$HOME/.config/docker/templates/compose.yaml.template" > "$STACK_DIR/compose.yaml"
        ;;
      web)
        cat > "$STACK_DIR/compose.yaml" << EOF
    # Docker Compose for web application stack: $STACK_NAME

    version: '3.8'

    services:
      app:
        image: your-app-image:latest
        container_name: ${STACK_NAME}-app
        restart: unless-stopped
        environment:
          - TZ=UTC
        volumes:
          - ./data:/data
        networks:
          - ${STACK_NAME}-network

      nginx:
        image: nginx:alpine
        container_name: ${STACK_NAME}-nginx
        restart: unless-stopped
        ports:
          - "8080:80"
        volumes:
          - ./config/nginx:/etc/nginx/conf.d
          - ./logs/nginx:/var/log/nginx
        networks:
          - ${STACK_NAME}-network
        depends_on:
          - app

    networks:
      ${STACK_NAME}-network:
        name: ${STACK_NAME}-network

    volumes:
      data:
        name: ${STACK_NAME}-data
    EOF

        # Create nginx config
        mkdir -p "$STACK_DIR/config/nginx"
        cat > "$STACK_DIR/config/nginx/default.conf" << EOF
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://${STACK_NAME}-app:8000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
    EOF
        ;;
      database)
        cat > "$STACK_DIR/compose.yaml" << EOF
    # Docker Compose for database stack: $STACK_NAME

    version: '3.8'

    services:
      db:
        image: postgres:14-alpine
        container_name: ${STACK_NAME}-db
        restart: unless-stopped
        environment:
          - POSTGRES_PASSWORD=postgres
          - POSTGRES_USER=postgres
          - POSTGRES_DB=${STACK_NAME}
          - TZ=UTC
        volumes:
          - ./data/postgres:/var/lib/postgresql/data
        ports:
          - "5432:5432"
        networks:
          - ${STACK_NAME}-network

      adminer:
        image: adminer
        container_name: ${STACK_NAME}-adminer
        restart: unless-stopped
        ports:
          - "8080:8080"
        networks:
          - ${STACK_NAME}-network
        depends_on:
          - db

    networks:
      ${STACK_NAME}-network:
        name: ${STACK_NAME}-network
    EOF
        ;;
      *)
        echo "Error: Unknown template: $TEMPLATE"
        exit 1
        ;;
    esac

    # Create .env file
    cat > "$STACK_DIR/.env" << EOF
    # Environment variables for $STACK_NAME stack
    STACK_NAME=$STACK_NAME
    EOF

    # Create README.md
    cat > "$STACK_DIR/README.md" << EOF
    # $STACK_NAME Stack

    Docker Compose stack created with stack-init.

    ## Usage

    ```bash
    # Start the stack
    docker compose up -d

    # View logs
    docker compose logs -f

    # Stop the stack
    docker compose down
    ```
    EOF

    echo ""
    echo "Stack created successfully at $STACK_DIR"
    echo ""
    echo "To start the stack:"
    echo "  cd $STACK_DIR"
    echo "  docker compose up -d"
    echo ""
    echo "May the blessings of Dockerus, the Container Oracle, be upon your containers!"
  '';

  # Add Docker completion for Bash
  programs.bash.initExtra = ''
    # Docker completion
    if [ -f ${pkgs.docker}/share/bash-completion/completions/docker ]; then
      source ${pkgs.docker}/share/bash-completion/completions/docker
    fi

    # Docker Compose completion
    if [ -f ${pkgs.docker-compose}/share/bash-completion/completions/docker-compose ]; then
      source ${pkgs.docker-compose}/share/bash-completion/completions/docker-compose
    fi
  '';
}
