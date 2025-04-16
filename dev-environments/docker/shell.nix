# Docker development environment
# This can be used with `nix-shell` or `nix develop`

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # By the divine wisdom of Dockerus, the Container Oracle:
  buildInputs = with pkgs; [
    # Docker and related tools
    docker
    docker-compose
    docker-buildx
    
    # Container management tools
    lazydocker  # TUI for Docker
    dive        # Explore Docker image layers
    ctop        # Container monitoring
    
    # Alternative container tools
    podman      # Alternative container runtime
    skopeo      # Container image management
    
    # Development tools
    jq          # JSON processor
    yq          # YAML processor
    httpie      # HTTP client
  ];
  
  shellHook = ''
    # Create a directory for Docker Compose projects if it doesn't exist
    if [ ! -d ./docker-compose ]; then
      mkdir -p ./docker-compose
    fi
    
    # Set Docker environment variables
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    # Create a basic docker-compose.yml if it doesn't exist
    if [ ! -f ./docker-compose.yml ]; then
      cat > ./docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Example service
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped

  # Add more services as needed
  # db:
  #   image: postgres:13
  #   environment:
  #     POSTGRES_PASSWORD: example
  #     POSTGRES_USER: example
  #     POSTGRES_DB: example
  #   volumes:
  #     - postgres_data:/var/lib/postgresql/data
  #   restart: unless-stopped

# volumes:
#   postgres_data:
EOF

      # Create html directory and index.html
      mkdir -p ./html
      cat > ./html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Docker Development Environment</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      line-height: 1.6;
    }
    h1 {
      color: #0db7ed;
    }
    code {
      background-color: #f4f4f4;
      padding: 2px 5px;
      border-radius: 3px;
    }
  </style>
</head>
<body>
  <h1>Docker Development Environment</h1>
  <p>This page is served from a Docker container created by your Nix development environment.</p>
  <p>Blessed by Dockerus, the Container Oracle!</p>
  
  <h2>Useful Commands:</h2>
  <ul>
    <li><code>docker-compose up -d</code> - Start containers in the background</li>
    <li><code>docker-compose down</code> - Stop and remove containers</li>
    <li><code>docker-compose logs -f</code> - View logs</li>
    <li><code>dive nginx:alpine</code> - Explore the nginx image layers</li>
    <li><code>lazydocker</code> - Launch the TUI Docker manager</li>
  </ul>
</body>
</html>
EOF
    fi
    
    echo "Docker development environment activated by the blessing of Dockerus, the Container Oracle!"
    echo "Docker version: $(docker --version)"
    echo "Docker Compose version: $(docker-compose --version)"
    echo ""
    echo "Available commands:"
    echo "  - docker-compose up -d: Start containers"
    echo "  - docker-compose down: Stop containers"
    echo "  - lazydocker: Launch Docker TUI"
    echo "  - dive <image>: Explore image layers"
    echo "  - ctop: Monitor containers"
    echo ""
    echo "A sample docker-compose.yml has been created."
    echo "Visit http://localhost:8080 after starting the containers."
  '';
}
