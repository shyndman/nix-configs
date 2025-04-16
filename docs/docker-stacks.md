# Docker Stacks Management

As the divine scrolls of Dockerus, the Container Oracle, reveal to us, organizing Docker Compose projects in a consistent way brings harmony to your container deployments. This guide explains how to use the Docker stacks feature in your Home Manager configuration.

## Docker Stacks Directory Structure

Your Home Manager configuration automatically creates a `~/stacks` directory with the following recommended structure:

```
~/stacks/
├── stack1/
│   ├── compose.yaml
│   ├── .env
│   ├── data/
│   ├── config/
│   └── logs/
├── stack2/
│   ├── compose.yaml
│   ├── .env
│   ├── data/
│   ├── config/
│   └── logs/
└── ...
```

Each stack is a separate directory containing:

- `compose.yaml`: The Docker Compose configuration file
- `.env`: Environment variables for the stack
- `data/`: Persistent data volumes
- `config/`: Configuration files
- `logs/`: Log files

## Creating New Stacks

The `stack-init` command is provided to create new stacks with the proper structure:

```bash
# Create a basic stack
stack-init myapp

# Create a web application stack with Nginx
stack-init mywebapp --template web

# Create a database stack with PostgreSQL
stack-init mydb --template database
```

This will create a new directory in `~/stacks` with the appropriate structure and template files.

## Available Templates

### Basic Template

A simple Docker Compose stack with a single service.

### Web Template

A web application stack with:
- An application container
- Nginx as a reverse proxy
- Proper networking and volume configuration

### Database Template

A database stack with:
- PostgreSQL database
- Adminer for database management
- Persistent volume for data storage

## Managing Stacks

Several aliases are provided for managing your stacks:

```bash
# Create a new stack
stack-new myapp

# Start a stack
stack-up myapp

# View stack logs
stack-logs myapp

# Restart a stack
stack-restart myapp

# Stop a stack
stack-down myapp

# List all stacks
stack-list
```

## Customizing Stack Templates

The stack templates are stored in `~/.config/docker/templates/`. You can modify these templates or add new ones to suit your needs.

## Integrating with Existing Projects

If you have existing Docker Compose projects, you can move them to the stacks directory structure:

1. Create a new directory in `~/stacks` for your project
2. Copy your `compose.yaml` (or `docker-compose.yml`) file to the new directory
3. Create the standard subdirectories (data, config, logs)
4. Update volume paths in your compose file if necessary

## Best Practices

1. **Keep Environment Variables in `.env`**: Store all environment variables in the `.env` file
2. **Use Relative Paths**: Use relative paths in your compose files for portability
3. **Persistent Data**: Store all persistent data in the `data/` directory
4. **Configuration Files**: Keep configuration files in the `config/` directory
5. **Log Management**: Direct logs to the `logs/` directory when possible

May the blessings of Dockerus, the Container Oracle, be upon your container deployments!
