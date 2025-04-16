# Python module for Home Manager
# This module configures Python and related tools

{ config, pkgs, lib, ... }:

let
  # Define Python versions to install
  pythonVersions = with pkgs; [
    python38
    python39
    python310
    python311
  ];
  
  # Create a Python environment with common packages
  pythonWithPackages = pkgs.python311.withPackages (ps: with ps; [
    # Core utilities
    pip
    setuptools
    wheel
    virtualenv
    pipx
    
    # Development tools
    black
    flake8
    mypy
    pytest
    pytest-cov
    
    # Data science
    numpy
    pandas
    matplotlib
    
    # Web development
    requests
    flask
    fastapi
  ]);
in
{
  # As Pythus, the Indentation Deity, has decreed:
  
  # Install Python and related tools
  home.packages = with pkgs; [
    # Multiple Python versions
    pythonWithPackages
  ] ++ pythonVersions ++ [
    # Python package managers and environment tools
    poetry
    pipenv
    
    # Python language server and tools
    nodePackages.pyright
    python311Packages.python-lsp-server
    
    # Build dependencies
    gcc
    gnumake
    
    # Jupyter
    jupyter
    
    # Documentation
    python311Packages.sphinx
  ];
  
  # Python shell aliases
  programs.bash.shellAliases = {
    # Python
    py = "python";
    py3 = "python3";
    ipy = "ipython";
    jn = "jupyter notebook";
    jl = "jupyter lab";
    
    # Virtual environments
    venv = "python -m venv .venv";
    activate = "source .venv/bin/activate";
    
    # Package management
    pipi = "pip install";
    pipu = "pip install --upgrade";
    pipun = "pip uninstall";
    pipl = "pip list";
    
    # Poetry
    po = "poetry";
    posh = "poetry shell";
    poin = "poetry install";
    poup = "poetry update";
    poad = "poetry add";
    porm = "poetry remove";
    
    # Testing and linting
    pytest = "python -m pytest";
    black = "python -m black";
    flake8 = "python -m flake8";
    mypy = "python -m mypy";
  };
  
  # ZSH configuration for Python
  programs.zsh.shellAliases = {
    # Python
    py = "python";
    py3 = "python3";
    ipy = "ipython";
    jn = "jupyter notebook";
    jl = "jupyter lab";
    
    # Virtual environments
    venv = "python -m venv .venv";
    activate = "source .venv/bin/activate";
    
    # Package management
    pipi = "pip install";
    pipu = "pip install --upgrade";
    pipun = "pip uninstall";
    pipl = "pip list";
    
    # Poetry
    po = "poetry";
    posh = "poetry shell";
    poin = "poetry install";
    poup = "poetry update";
    poad = "poetry add";
    porm = "poetry remove";
    
    # Testing and linting
    pytest = "python -m pytest";
    black = "python -m black";
    flake8 = "python -m flake8";
    mypy = "python -m mypy";
  };
  
  # Add Python ZSH plugin if using Oh-My-Zsh
  programs.zsh.oh-my-zsh = lib.mkIf config.programs.zsh.oh-my-zsh.enable {
    plugins = [ "python" "pip" "virtualenv" ];
  };
  
  # Python environment variables
  home.sessionVariables = {
    PYTHONDONTWRITEBYTECODE = "1";  # Don't create .pyc files
    PYTHONUNBUFFERED = "1";         # Don't buffer output
    VIRTUAL_ENV_DISABLE_PROMPT = "1"; # Let the shell handle the prompt
  };
  
  # Create a pyenv-like script to switch between Python versions
  home.file.".local/bin/pyswitch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # pyswitch - A script to switch between Python versions in Nix
      # Inspired by the sacred teachings of Pythus, the Indentation Deity
      
      set -e
      
      PYTHON_VERSIONS=(
        "${pkgs.python38}/bin/python"
        "${pkgs.python39}/bin/python"
        "${pkgs.python310}/bin/python"
        "${pkgs.python311}/bin/python"
      )
      
      VERSION_NAMES=(
        "Python 3.8"
        "Python 3.9"
        "Python 3.10"
        "Python 3.11"
      )
      
      function show_help {
        echo "pyswitch - Switch between Python versions"
        echo ""
        echo "Usage: pyswitch [version]"
        echo ""
        echo "Available versions:"
        for i in "''${!VERSION_NAMES[@]}"; do
          echo "  ''${i}: ''${VERSION_NAMES[$i]}"
        done
        echo ""
        echo "Examples:"
        echo "  pyswitch 3       # Switch to Python 3.11"
        echo "  pyswitch list    # List available versions"
        echo "  pyswitch current # Show current version"
      }
      
      function list_versions {
        echo "Available Python versions:"
        for i in "''${!VERSION_NAMES[@]}"; do
          echo "  ''${i}: ''${VERSION_NAMES[$i]} (''${PYTHON_VERSIONS[$i]})"
        done
      }
      
      function show_current {
        current_python=$(readlink -f ~/.local/bin/python 2>/dev/null || which python)
        echo "Current Python: $current_python ($(python --version))"
      }
      
      function switch_version {
        if [[ ! $1 =~ ^[0-9]+$ ]]; then
          echo "Error: Version must be a number"
          exit 1
        fi
        
        if [ $1 -ge ''${#PYTHON_VERSIONS[@]} ]; then
          echo "Error: Version $1 not available"
          list_versions
          exit 1
        fi
        
        mkdir -p ~/.local/bin
        
        # Create symlinks
        ln -sf "''${PYTHON_VERSIONS[$1]}" ~/.local/bin/python
        
        echo "Switched to ''${VERSION_NAMES[$1]}"
        show_current
      }
      
      case "$1" in
        help|--help|-h)
          show_help
          ;;
        list|--list|-l)
          list_versions
          ;;
        current|--current|-c)
          show_current
          ;;
        "")
          show_help
          ;;
        *)
          switch_version "$1"
          ;;
      esac
    '';
  };
  
  # Create a directory for Python projects
  home.file."python-projects/.gitkeep".text = "";
  
  # Create a default pip.conf
  home.file.".config/pip/pip.conf".text = ''
    [global]
    timeout = 60
    index-url = https://pypi.org/simple
    trusted-host = pypi.org
  '';
  
  # Create a default pyproject.toml template
  home.file.".config/python/pyproject.toml.template".text = ''
    [tool.poetry]
    name = "project-name"
    version = "0.1.0"
    description = "A Python project blessed by Pythus, the Indentation Deity"
    authors = ["Your Name <your.email@example.com>"]
    readme = "README.md"

    [tool.poetry.dependencies]
    python = "^3.11"

    [tool.poetry.group.dev.dependencies]
    pytest = "^7.3.1"
    black = "^23.3.0"
    flake8 = "^6.0.0"
    mypy = "^1.3.0"

    [build-system]
    requires = ["poetry-core"]
    build-backend = "poetry.core.masonry.api"
    
    [tool.black]
    line-length = 88
    
    [tool.mypy]
    python_version = "3.11"
    warn_return_any = true
    warn_unused_configs = true
    disallow_untyped_defs = true
    disallow_incomplete_defs = true
    
    [tool.pytest.ini_options]
    testpaths = ["tests"]
    python_files = "test_*.py"
  '';
  
  # Add a script to create new Python projects
  home.file.".local/bin/pynew" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # pynew - A script to create new Python projects
      # Blessed by Pythus, the Indentation Deity
      
      set -e
      
      function show_help {
        echo "pynew - Create a new Python project"
        echo ""
        echo "Usage: pynew [project_name] [--type TYPE]"
        echo ""
        echo "Types:"
        echo "  basic    - Basic Python project (default)"
        echo "  poetry   - Poetry project"
        echo "  fastapi  - FastAPI project"
        echo "  flask    - Flask project"
        echo "  cli      - Command-line tool"
        echo "  package  - Python package"
        echo ""
        echo "Examples:"
        echo "  pynew myproject"
        echo "  pynew myapi --type fastapi"
      }
      
      PROJECT_NAME=""
      PROJECT_TYPE="basic"
      
      # Parse arguments
      while [[ $# -gt 0 ]]; do
        case $1 in
          --type|-t)
            PROJECT_TYPE="$2"
            shift 2
            ;;
          --help|-h)
            show_help
            exit 0
            ;;
          *)
            if [ -z "$PROJECT_NAME" ]; then
              PROJECT_NAME="$1"
            else
              echo "Error: Unknown argument $1"
              show_help
              exit 1
            fi
            shift
            ;;
        esac
      done
      
      if [ -z "$PROJECT_NAME" ]; then
        echo "Error: Project name is required"
        show_help
        exit 1
      fi
      
      if [ -d "$PROJECT_NAME" ]; then
        echo "Error: Directory $PROJECT_NAME already exists"
        exit 1
      fi
      
      echo "Creating $PROJECT_TYPE project: $PROJECT_NAME"
      
      # Create project directory
      mkdir -p "$PROJECT_NAME"
      cd "$PROJECT_NAME"
      
      # Create basic structure
      mkdir -p "$PROJECT_NAME" tests docs
      
      # Create README
      cat > README.md << EOF
      # $PROJECT_NAME
      
      A Python project blessed by Pythus, the Indentation Deity.
      
      ## Installation
      
      \`\`\`bash
      # Clone the repository
      git clone https://github.com/yourusername/$PROJECT_NAME.git
      cd $PROJECT_NAME
      
      # Create a virtual environment
      python -m venv .venv
      source .venv/bin/activate
      
      # Install dependencies
      pip install -e .
      \`\`\`
      
      ## Usage
      
      \`\`\`python
      from $PROJECT_NAME import example
      
      example.hello_world()
      \`\`\`
      
      ## Development
      
      \`\`\`bash
      # Install development dependencies
      pip install -e ".[dev]"
      
      # Run tests
      pytest
      
      # Format code
      black .
      
      # Check types
      mypy .
      \`\`\`
      EOF
      
      # Create __init__.py
      cat > "$PROJECT_NAME/__init__.py" << EOF
      """$PROJECT_NAME package."""
      
      __version__ = "0.1.0"
      EOF
      
      # Create example.py
      cat > "$PROJECT_NAME/example.py" << EOF
      """Example module."""
      
      
      def hello_world() -> str:
          """Return a greeting.
          
          Returns:
              str: A friendly greeting
          """
          return "Hello, World!"
      EOF
      
      # Create test file
      cat > "tests/test_example.py" << EOF
      """Tests for the example module."""
      
      from $PROJECT_NAME import example
      
      
      def test_hello_world():
          """Test the hello_world function."""
          assert example.hello_world() == "Hello, World!"
      EOF
      
      # Create project-specific files based on type
      case "$PROJECT_TYPE" in
        basic)
          # Create setup.py
          cat > "setup.py" << EOF
      from setuptools import setup, find_packages
      
      setup(
          name="$PROJECT_NAME",
          version="0.1.0",
          packages=find_packages(),
          install_requires=[],
          extras_require={
              "dev": [
                  "pytest",
                  "black",
                  "flake8",
                  "mypy",
              ],
          },
      )
      EOF
          ;;
          
        poetry)
          # Initialize poetry
          poetry init --name="$PROJECT_NAME" --description="A Python project" --author="Your Name <your.email@example.com>" --python="^3.11" --no-interaction
          poetry add --group dev pytest black flake8 mypy
          ;;
          
        fastapi)
          # Create setup.py with FastAPI dependencies
          cat > "setup.py" << EOF
      from setuptools import setup, find_packages
      
      setup(
          name="$PROJECT_NAME",
          version="0.1.0",
          packages=find_packages(),
          install_requires=[
              "fastapi",
              "uvicorn",
              "pydantic",
          ],
          extras_require={
              "dev": [
                  "pytest",
                  "black",
                  "flake8",
                  "mypy",
                  "httpx",
              ],
          },
      )
      EOF
          
          # Create app.py
          cat > "$PROJECT_NAME/app.py" << EOF
      """FastAPI application."""
      
      from fastapi import FastAPI
      
      app = FastAPI(title="$PROJECT_NAME")
      
      
      @app.get("/")
      async def root():
          """Root endpoint.
          
          Returns:
              dict: A greeting message
          """
          return {"message": "Hello, World!"}
      EOF
          
          # Create main.py
          cat > "$PROJECT_NAME/main.py" << EOF
      """Main module for running the FastAPI application."""
      
      import uvicorn
      
      from $PROJECT_NAME.app import app
      
      if __name__ == "__main__":
          uvicorn.run("$PROJECT_NAME.app:app", host="0.0.0.0", port=8000, reload=True)
      EOF
          ;;
          
        flask)
          # Create setup.py with Flask dependencies
          cat > "setup.py" << EOF
      from setuptools import setup, find_packages
      
      setup(
          name="$PROJECT_NAME",
          version="0.1.0",
          packages=find_packages(),
          install_requires=[
              "flask",
          ],
          extras_require={
              "dev": [
                  "pytest",
                  "black",
                  "flake8",
                  "mypy",
              ],
          },
      )
      EOF
          
          # Create app.py
          cat > "$PROJECT_NAME/app.py" << EOF
      """Flask application."""
      
      from flask import Flask
      
      app = Flask(__name__)
      
      
      @app.route("/")
      def hello_world():
          """Root endpoint.
          
          Returns:
              str: A greeting message
          """
          return "Hello, World!"
      
      
      if __name__ == "__main__":
          app.run(debug=True)
      EOF
          ;;
          
        cli)
          # Create setup.py with CLI dependencies
          cat > "setup.py" << EOF
      from setuptools import setup, find_packages
      
      setup(
          name="$PROJECT_NAME",
          version="0.1.0",
          packages=find_packages(),
          install_requires=[
              "click",
          ],
          extras_require={
              "dev": [
                  "pytest",
                  "black",
                  "flake8",
                  "mypy",
              ],
          },
          entry_points={
              "console_scripts": [
                  "$PROJECT_NAME=$PROJECT_NAME.cli:main",
              ],
          },
      )
      EOF
          
          # Create cli.py
          cat > "$PROJECT_NAME/cli.py" << EOF
      """Command-line interface."""
      
      import click
      
      
      @click.group()
      def cli():
          """$PROJECT_NAME CLI."""
          pass
      
      
      @cli.command()
      @click.option("--name", default="World", help="Name to greet")
      def hello(name):
          """Greet the user."""
          click.echo(f"Hello, {name}!")
      
      
      def main():
          """Run the CLI."""
          cli()
      
      
      if __name__ == "__main__":
          main()
      EOF
          ;;
          
        package)
          # Create setup.py for a package
          cat > "setup.py" << EOF
      from setuptools import setup, find_packages
      
      with open("README.md", "r", encoding="utf-8") as fh:
          long_description = fh.read()
      
      setup(
          name="$PROJECT_NAME",
          version="0.1.0",
          author="Your Name",
          author_email="your.email@example.com",
          description="A Python package blessed by Pythus, the Indentation Deity",
          long_description=long_description,
          long_description_content_type="text/markdown",
          url="https://github.com/yourusername/$PROJECT_NAME",
          packages=find_packages(),
          classifiers=[
              "Programming Language :: Python :: 3",
              "License :: OSI Approved :: MIT License",
              "Operating System :: OS Independent",
          ],
          python_requires=">=3.8",
          install_requires=[],
          extras_require={
              "dev": [
                  "pytest",
                  "black",
                  "flake8",
                  "mypy",
                  "build",
                  "twine",
              ],
          },
      )
      EOF
          
          # Create MANIFEST.in
          cat > "MANIFEST.in" << EOF
      include README.md
      include LICENSE
      recursive-include tests *
      recursive-exclude * __pycache__
      recursive-exclude * *.py[cod]
      EOF
          
          # Create LICENSE
          cat > "LICENSE" << EOF
      MIT License
      
      Copyright (c) 2023 Your Name
      
      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:
      
      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
      EOF
          ;;
          
        *)
          echo "Error: Unknown project type: $PROJECT_TYPE"
          exit 1
          ;;
      esac
      
      # Create .gitignore
      cat > ".gitignore" << EOF
      # Byte-compiled / optimized / DLL files
      __pycache__/
      *.py[cod]
      *$py.class
      
      # Distribution / packaging
      dist/
      build/
      *.egg-info/
      
      # Unit test / coverage reports
      htmlcov/
      .tox/
      .coverage
      .coverage.*
      .cache
      coverage.xml
      *.cover
      
      # Virtual environments
      .venv/
      venv/
      ENV/
      
      # Environment variables
      .env
      
      # IDE files
      .idea/
      .vscode/
      *.swp
      *~
      EOF
      
      # Initialize git repository
      git init
      
      echo ""
      echo "Project created successfully!"
      echo ""
      echo "Next steps:"
      echo "  cd $PROJECT_NAME"
      echo "  python -m venv .venv"
      echo "  source .venv/bin/activate"
      
      if [ "$PROJECT_TYPE" = "poetry" ]; then
        echo "  poetry install"
      else
        echo "  pip install -e \".[dev]\""
      fi
      
      echo ""
      echo "May the blessings of Pythus, the Indentation Deity, be upon your code!"
    '';
  };
}
