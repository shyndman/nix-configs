# Python with Nix

As Pythus, the Indentation Deity, has revealed to the faithful, Python and Nix can work together in harmony to create reproducible development environments. This guide explains how to use Python with Nix and Home Manager, including pyenv-like functionality.

## Python in Nix vs. Traditional Python Management

Traditional Python management tools like pyenv, virtualenv, and conda have their strengths, but Nix offers some unique advantages:

| Feature | Traditional Tools | Nix |
|---------|------------------|-----|
| Multiple Python versions | ✅ (pyenv) | ✅ |
| Isolated environments | ✅ (virtualenv, venv) | ✅ |
| Reproducibility | ⚠️ (limited) | ✅ (guaranteed) |
| System integration | ⚠️ (can conflict) | ✅ (isolated) |
| Package management | ✅ (pip, conda) | ✅ (nixpkgs) |
| OS-level dependencies | ⚠️ (manual) | ✅ (automatic) |

## Installing Python with Home Manager

Home Manager can install Python and related tools for you:

```nix
# In your home.nix
home.packages = with pkgs; [
  python311
  python310
  python39
  python38
  poetry
  pipenv
];
```

## Using the Python Module

This repository includes a dedicated Python module that provides a comprehensive Python setup:

```nix
# In your home.nix
imports = [
  ./modules/python.nix
];
```

The module provides:
- Multiple Python versions
- Common Python packages
- Shell aliases for Python commands
- ZSH plugin configuration
- Python environment variables
- A pyenv-like script to switch between Python versions
- A script to create new Python projects

## Python Development Environment

A Python development environment with pyenv-like functionality is included in `dev-environments/python/shell.nix`. To use it:

```bash
# Enter the Python development environment
cd dev-environments/python
nix-shell

# Or with flakes
nix develop path:.#python
```

This environment provides:
- Multiple Python versions (3.8, 3.9, 3.10, 3.11)
- A script to switch between versions (`pyswitch`)
- A script to create new Python projects (`pynew`)
- Common Python packages and tools

## Switching Between Python Versions

The `pyswitch` command allows you to switch between Python versions:

```bash
# List available Python versions
pyswitch list

# Switch to Python 3.8
pyswitch 0

# Switch to Python 3.9
pyswitch 1

# Switch to Python 3.10
pyswitch 2

# Switch to Python 3.11
pyswitch 3

# Show current Python version
pyswitch current
```

## Creating New Python Projects

The `pynew` command helps you create new Python projects:

```bash
# Create a basic Python project
pynew myproject

# Create a FastAPI project
pynew myapi --type fastapi

# Create a Flask project
pynew mywebapp --type flask

# Create a CLI tool
pynew mytool --type cli

# Create a data science project
pynew myanalysis --type data

# Create a Poetry project
pynew mylib --type poetry
```

## Python Virtual Environments with Nix

While Nix provides isolated environments, you might still want to use virtual environments for project-specific dependencies:

```bash
# Create a virtual environment
python -m venv .venv

# Activate the virtual environment
source .venv/bin/activate

# Install dependencies
pip install -e ".[dev]"
```

## Advanced Python with Nix Techniques

### 1. Creating a Custom Python Environment

You can create a custom Python environment with specific packages:

```nix
let
  myPython = pkgs.python311.withPackages (ps: with ps; [
    # Data science
    numpy
    pandas
    matplotlib
    scikit-learn
    
    # Web development
    flask
    requests
    
    # Development tools
    black
    pytest
  ]);
in
{
  home.packages = [ myPython ];
}
```

### 2. Python Development Shell for a Project

Create a `shell.nix` file in your project:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python311.withPackages (ps: with ps; [
      # Project dependencies
      flask
      sqlalchemy
      
      # Development tools
      black
      pytest
      mypy
    ]))
  ];
  
  shellHook = ''
    # Create and activate a virtual environment
    python -m venv .venv
    source .venv/bin/activate
    
    # Set up environment variables
    export FLASK_APP=myapp
    export FLASK_ENV=development
  '';
}
```

### 3. Building a Python Application with Nix

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.python311Packages.buildPythonApplication {
  pname = "myapp";
  version = "0.1.0";
  src = ./.;
  
  propagatedBuildInputs = with pkgs.python311Packages; [
    flask
    sqlalchemy
  ];
  
  checkInputs = with pkgs.python311Packages; [
    pytest
  ];
  
  checkPhase = ''
    pytest
  '';
}
```

### 4. Using Poetry with Nix

For Poetry projects, you can use the `poetry2nix` tool:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  poetry2nix = import (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "1.40.0";
    sha256 = "0l8xc3yh7p0r1k9x1cw9czs3n2qzxvfxg5x8xr8929yc448df5jv";
  }) {
    inherit pkgs;
  };
in
poetry2nix.mkPoetryApplication {
  projectDir = ./.;
}
```

## Best Practices

### 1. Use Nix for Development Environment, pip for Project Dependencies

A good pattern is to use Nix to provide the Python interpreter and development tools, but use pip/poetry within a virtual environment for project-specific dependencies:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    poetry
  ];
  
  shellHook = ''
    # Create a virtual environment if it doesn't exist
    if [ ! -d .venv ]; then
      python -m venv .venv
    fi
    
    # Activate the virtual environment
    source .venv/bin/activate
    
    # Install dependencies if needed
    if [ ! -f .venv/.installed ]; then
      poetry install
      touch .venv/.installed
    fi
  '';
}
```

### 2. Pin Python and Package Versions

Always specify exact versions of Python and packages:

```nix
python311  # Instead of just python
```

### 3. Use direnv for Automatic Environment Activation

Create a `.envrc` file in your Python project:

```
use nix
```

This automatically activates your Nix environment when entering the directory.

### 4. Separate Development and Runtime Dependencies

```nix
# In setup.py or pyproject.toml
extras_require = {
  "dev": [
    "pytest",
    "black",
    "mypy",
  ],
}
```

## Troubleshooting

### Common Issues

1. **Missing System Libraries**
   - Nix isolates packages, so you might need to include system libraries in your shell
   - Add them to `buildInputs` in your `shell.nix`

2. **Package Conflicts**
   - Use `python.withPackages` to create a consistent set of packages
   - Or use virtual environments for project-specific dependencies

3. **Import Errors**
   - Ensure `PYTHONPATH` is set correctly in your shell hook
   - Use `sys.path.append` in scripts if needed

4. **Binary Extensions**
   - Some Python packages with C extensions might need additional build inputs
   - Add them to `buildInputs` in your `shell.nix`

May the blessings of Pythus, the Indentation Deity, guide your Python development journey!
