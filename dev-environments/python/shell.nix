# Advanced Python development environment with pyenv-like functionality
# This can be used with `nix-shell` or `nix develop`

{ pkgs ? import <nixpkgs> {} }:

let
  # Define available Python versions
  pythonVersions = {
    py38 = pkgs.python38;
    py39 = pkgs.python39;
    py310 = pkgs.python310;
    py311 = pkgs.python311;
  };

  # Default Python version
  defaultPython = pythonVersions.py311;

  # Function to create a Python environment with packages
  pythonWithPackages = python: python.withPackages (ps: with ps; [
    # Core tools
    pip
    setuptools
    wheel
    virtualenv
    pipx

    # Data science packages
    numpy
    pandas
    matplotlib
    jupyter
    scikit-learn

    # Web development
    flask
    fastapi
    requests
    httpx
    uvicorn

    # Development tools
    black
    flake8
    mypy
    pytest
    pytest-cov
    isort
  ]);

  # Create Python environments for each version
  pythonEnvironments = builtins.mapAttrs (name: python: pythonWithPackages python) pythonVersions;

  # Create a script to switch between Python versions
  pythonSwitchScript = pkgs.writeScriptBin "pyswitch" ''
    #!/usr/bin/env bash

    # pyswitch - A script to switch between Python versions in the current shell
    # Blessed by Pythus, the Indentation Deity

    set -e

    PYTHON_VERSIONS=(
      "${pythonVersions.py38}/bin/python"
      "${pythonVersions.py39}/bin/python"
      "${pythonVersions.py310}/bin/python"
      "${pythonVersions.py311}/bin/python"
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
      echo "Current Python: $(which python) ($(python --version))"
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

      # Create a new Python wrapper script
      cat > "$PYSWITCH_DIR/python" << EOF
    #!/usr/bin/env bash
    exec "''${PYTHON_VERSIONS[$1]}" "\$@"
    EOF
      chmod +x "$PYSWITCH_DIR/python"

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

  # Create a script to create new Python projects
  pynewScript = pkgs.writeScriptBin "pynew" ''
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
      echo "  data     - Data science project"
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
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Create basic structure
    mkdir -p "$PROJECT_NAME" tests

    # Create README
    cat > README.md << EOF
    # $PROJECT_NAME

    A Python project blessed by Pythus, the Indentation Deity.

    ## Installation

    \`\`\`bash
    # Create a virtual environment
    python -m venv .venv
    source .venv/bin/activate

    # Install dependencies
    pip install -e .
    \`\`\`

    ## Development

    \`\`\`bash
    # Install development dependencies
    pip install -e ".[dev]"

    # Run tests
    pytest

    # Format code
    black .
    \`\`\`
    EOF

    # Create __init__.py
    cat > "$PROJECT_NAME/__init__.py" << EOF
    """$PROJECT_NAME package."""

    __version__ = "0.1.0"
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
        # Create main.py
        cat > "$PROJECT_NAME/main.py" << EOF
    """FastAPI application."""

    from fastapi import FastAPI
    import uvicorn

    app = FastAPI(title="$PROJECT_NAME")


    @app.get("/")
    async def root():
        """Root endpoint.

        Returns:
            dict: A greeting message
        """
        return {"message": "Hello, World!"}


    if __name__ == "__main__":
        uvicorn.run("$PROJECT_NAME.main:app", host="0.0.0.0", port=8000, reload=True)
    EOF

        # Create setup.py
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
        ;;

      flask)
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

        # Create setup.py
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
        ;;

      cli)
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

        # Create setup.py
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
        ;;

      data)
        # Create data_analysis.py
        cat > "$PROJECT_NAME/data_analysis.py" << EOF
    """Data analysis module."""

    import pandas as pd
    import matplotlib.pyplot as plt
    import numpy as np


    def load_data(file_path):
        """Load data from a file.

        Args:
            file_path: Path to the data file

        Returns:
            pandas.DataFrame: The loaded data
        """
        # Example implementation - modify as needed
        return pd.read_csv(file_path)


    def analyze_data(data):
        """Perform basic analysis on the data.

        Args:
            data: pandas.DataFrame with the data to analyze

        Returns:
            dict: Analysis results
        """
        return {
            "summary": data.describe(),
            "columns": data.columns.tolist(),
            "missing": data.isnull().sum().to_dict(),
        }


    def plot_data(data, column, save_path=None):
        """Create a plot of the data.

        Args:
            data: pandas.DataFrame with the data to plot
            column: Column to plot
            save_path: Path to save the plot (optional)
        """
        plt.figure(figsize=(10, 6))
        data[column].plot(kind="hist")
        plt.title(f"Distribution of {column}")
        plt.xlabel(column)
        plt.ylabel("Frequency")

        if save_path:
            plt.savefig(save_path)
        else:
            plt.show()
    EOF

        # Create setup.py
        cat > "setup.py" << EOF
    from setuptools import setup, find_packages

    setup(
        name="$PROJECT_NAME",
        version="0.1.0",
        packages=find_packages(),
        install_requires=[
            "pandas",
            "numpy",
            "matplotlib",
            "scikit-learn",
            "jupyter",
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

        # Create a notebook
        mkdir -p notebooks
        cat > "notebooks/analysis.ipynb" << EOF
    {
     "cells": [
      {
       "cell_type": "markdown",
       "metadata": {},
       "source": [
        "# $PROJECT_NAME Analysis"
       ]
      },
      {
       "cell_type": "code",
       "execution_count": null,
       "metadata": {},
       "outputs": [],
       "source": [
        "import pandas as pd\n",
        "import numpy as np\n",
        "import matplotlib.pyplot as plt\n",
        "\n",
        "# Set up plotting\n",
        "%matplotlib inline\n",
        "plt.style.use('seaborn-whitegrid')\n",
        "\n",
        "# Import project modules\n",
        "import sys\n",
        "sys.path.append('..')\n",
        "from $PROJECT_NAME import data_analysis"
       ]
      },
      {
       "cell_type": "markdown",
       "metadata": {},
       "source": [
        "## Load Data"
       ]
      },
      {
       "cell_type": "code",
       "execution_count": null,
       "metadata": {},
       "outputs": [],
       "source": [
        "# Example: Create some sample data\n",
        "data = pd.DataFrame({\n",
        "    'x': np.random.normal(0, 1, 1000),\n",
        "    'y': np.random.normal(0, 1, 1000),\n",
        "    'category': np.random.choice(['A', 'B', 'C'], 1000)\n",
        "})\n",
        "\n",
        "data.head()"
       ]
      },
      {
       "cell_type": "markdown",
       "metadata": {},
       "source": [
        "## Analyze Data"
       ]
      },
      {
       "cell_type": "code",
       "execution_count": null,
       "metadata": {},
       "outputs": [],
       "source": [
        "# Use the project's analysis function\n",
        "results = data_analysis.analyze_data(data)\n",
        "\n",
        "# Display summary statistics\n",
        "results['summary']"
       ]
      },
      {
       "cell_type": "markdown",
       "metadata": {},
       "source": [
        "## Visualize Data"
       ]
      },
      {
       "cell_type": "code",
       "execution_count": null,
       "metadata": {},
       "outputs": [],
       "source": [
        "# Create a scatter plot\n",
        "plt.figure(figsize=(10, 6))\n",
        "for category, group in data.groupby('category'):\n",
        "    plt.scatter(group['x'], group['y'], label=category, alpha=0.6)\n",
        "\n",
        "plt.title('Scatter Plot by Category')\n",
        "plt.xlabel('X')\n",
        "plt.ylabel('Y')\n",
        "plt.legend()\n",
        "plt.show()"
       ]
      }
     ],
     "metadata": {
      "kernelspec": {
       "display_name": "Python 3",
       "language": "python",
       "name": "python3"
      },
      "language_info": {
       "codemirror_mode": {
        "name": "ipython",
        "version": 3
       },
       "file_extension": ".py",
       "mimetype": "text/x-python",
       "name": "python",
       "nbconvert_exporter": "python",
       "pygments_lexer": "ipython3",
       "version": "3.11.0"
      }
     },
     "nbformat": 4,
     "nbformat_minor": 4
    }
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

    # Jupyter Notebook
    .ipynb_checkpoints
    EOF

    # Create a test file
    mkdir -p tests
    cat > "tests/test_$PROJECT_NAME.py" << EOF
    """Tests for the $PROJECT_NAME package."""

    import pytest
    from $PROJECT_NAME import __version__


    def test_version():
        """Test the version is a string."""
        assert isinstance(__version__, str)
    EOF

    # Create a virtual environment
    python -m venv .venv

    echo ""
    echo "Project created successfully!"
    echo ""
    echo "Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  source .venv/bin/activate"

    if [ "$PROJECT_TYPE" = "poetry" ]; then
      echo "  poetry install"
    else
      echo "  pip install -e \".[dev]\""
    fi

    echo ""
    echo "May the blessings of Pythus, the Indentation Deity, be upon your code!"
  '';
in
pkgs.mkShell {
  # As the prophet Pythus, the Indentation Deity, commands:
  buildInputs = [
    # Python environments for all versions
    pythonEnvironments.py38
    pythonEnvironments.py39
    pythonEnvironments.py310
    pythonEnvironments.py311

    # Default to Python 3.11
    defaultPython

    # Python package managers and tools
    pkgs.poetry
    pkgs.pipenv

    # Python version switching script
    pythonSwitchScript

    # Project creation script
    pynewScript

    # Build dependencies
    pkgs.gcc
    pkgs.gnumake
  ];

  shellHook = ''
    # Create a directory for pyswitch
    export PYSWITCH_DIR="$PWD/.pyswitch"
    mkdir -p "$PYSWITCH_DIR"

    # Add pyswitch directory to PATH
    export PATH="$PYSWITCH_DIR:$PATH"

    # Set up Python 3.11 as default
    if [ ! -f "$PYSWITCH_DIR/python" ]; then
      cat > "$PYSWITCH_DIR/python" << EOF
    #!/usr/bin/env bash
    exec "${defaultPython}/bin/python" "\$@"
    EOF
      chmod +x "$PYSWITCH_DIR/python"
    fi

    # Create a virtual environment if it doesn't exist
    if [ ! -d .venv ]; then
      echo "Creating virtual environment..."
      python -m venv .venv
    fi

    # Activate the virtual environment
    source .venv/bin/activate

    # Set up environment variables
    export PYTHONPATH="$PWD:$PYTHONPATH"
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1

    echo "Python development environment activated by the grace of Pythus, the Indentation Deity!"
    echo "Python version: $(python --version)"
    echo ""
    echo "Available commands:"
    echo "  - pyswitch <version>: Switch Python version (0=3.8, 1=3.9, 2=3.10, 3=3.11)"
    echo "  - pyswitch list: List available Python versions"
    echo "  - pynew <project>: Create a new Python project"
    echo "  - black .: Format code"
    echo "  - flake8 .: Lint code"
    echo "  - pytest: Run tests"
    echo "  - mypy .: Type check"
    echo ""
    echo "Available Python versions:"
    pyswitch list
  '';
}
