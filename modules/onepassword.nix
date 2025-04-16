# 1Password module for Home Manager
# This module configures 1Password CLI and integrations

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.onepassword;
in
{
  options.modules.onepassword = {
    enable = lib.mkEnableOption "1Password integration";

    cli = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the 1Password CLI.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs._1password;
        description = "The 1Password CLI package to use.";
      };
    };

    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the 1Password GUI application.";
      };

      sshAgent = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to enable the 1Password SSH agent.";
        };
      };
    };

    secretsScript = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a script for loading 1Password secrets.";
      };
    };

    sshKeys = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to manage SSH authorized keys from 1Password.";
      };

      secretReferences = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of 1Password secret references to SSH public keys.";
        example = [ "op://Personal/SSH Key - Personal/public key" "op://Work/SSH Key - Work/public key" ];
      };

      updateInterval = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "How often to update the authorized_keys file from 1Password.";
        example = "hourly";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install 1Password CLI
    home.packages = lib.optional cfg.cli.enable cfg.cli.package;

    # Configure 1Password GUI and SSH agent
    programs._1password-gui = lib.mkIf cfg.gui.enable {
      enable = true;
      sshAgent.enable = cfg.gui.sshAgent.enable;
    };

    # Configure SSH to use 1Password SSH agent
    programs.ssh = lib.mkIf (cfg.gui.enable && cfg.gui.sshAgent.enable) {
      extraConfig = ''
        # Use 1Password SSH agent
        IdentityAgent ~/.1password/agent.sock
      '';
    };

    # Create a script for loading 1Password secrets
    home.file = lib.mkIf cfg.secretsScript.enable {
      ".local/bin/op-load-secrets" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # op-load-secrets - A script to load secrets from 1Password
          # Blessed by Onepassus, the Vault Keeper

          set -e

          # Check if 1Password CLI is installed
          if ! command -v op &> /dev/null; then
            echo "Error: 1Password CLI is not installed"
            exit 1
          fi

          # Sign in to 1Password if needed
          if ! op account get >/dev/null 2>&1; then
            echo "Signing in to 1Password..."
            eval $(op signin)
          fi

          # Function to get a secret from 1Password
          get_secret() {
            local vault="$1"
            local item="$2"
            local field="$3"

            op item get "$item" --vault "$vault" --fields "$field"
          }

          # Create secrets directory if it doesn't exist
          SECRETS_DIR="$HOME/.config/op-secrets"
          mkdir -p "$SECRETS_DIR"

          # Example: Get API keys and save them to environment files
          # Uncomment and modify these examples as needed

          # GitHub token
          # GITHUB_TOKEN=$(get_secret "Development" "GitHub" "token")
          # echo "export GITHUB_TOKEN=$GITHUB_TOKEN" > "$SECRETS_DIR/github.env"

          # AWS credentials
          # AWS_ACCESS_KEY=$(get_secret "Development" "AWS" "access_key")
          # AWS_SECRET_KEY=$(get_secret "Development" "AWS" "secret_key")
          # cat > "$SECRETS_DIR/aws.env" << EOF
          # export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
          # export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
          # EOF

          # Database credentials
          # DB_PASSWORD=$(get_secret "Development" "Database" "password")
          # echo "export DB_PASSWORD=$DB_PASSWORD" > "$SECRETS_DIR/database.env"

          echo "Secrets loaded successfully by the blessing of Onepassus, the Vault Keeper!"
          echo "To use these secrets, add 'source ~/.config/op-secrets/*.env' to your shell configuration."
        '';
      };

      # Create a wrapper for running commands with 1Password secrets
      ".local/bin/op-run" = lib.mkIf cfg.secretsScript.enable {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # op-run - Run a command with 1Password secrets
          # Blessed by Onepassus, the Vault Keeper

          set -e

          # Check if 1Password CLI is installed
          if ! command -v op &> /dev/null; then
            echo "Error: 1Password CLI is not installed"
            exit 1
          fi

          # Sign in to 1Password if needed
          if ! op account get >/dev/null 2>&1; then
            echo "Signing in to 1Password..."
            eval $(op signin)
          fi

          # Show help if no arguments provided
          if [ $# -eq 0 ]; then
            echo "Usage: op-run [--vault VAULT] [--item ITEM] [--env-file FILE] -- COMMAND [ARGS...]"
            echo ""
            echo "Options:"
            echo "  --vault VAULT    1Password vault to use"
            echo "  --item ITEM      1Password item to use"
            echo "  --env-file FILE  Save environment variables to this file"
            echo "  -- COMMAND       Command to run with the secrets"
            exit 1
          fi

          # Parse arguments
          VAULT=""
          ITEM=""
          ENV_FILE=""
          COMMAND_START=0

          for i in $(seq 1 $#); do
            arg="''${!i}"
            next=$((i+1))
            next_arg="''${!next}"

            case "$arg" in
              --vault)
                VAULT="$next_arg"
                ;;
              --item)
                ITEM="$next_arg"
                ;;
              --env-file)
                ENV_FILE="$next_arg"
                ;;
              --)
                COMMAND_START=$((i+1))
                break
                ;;
            esac
          done

          # Check if we have a command to run
          if [ $COMMAND_START -eq 0 ]; then
            echo "Error: No command specified"
            exit 1
          fi

          # Get the command and arguments
          COMMAND=("''${@:$COMMAND_START}")

          # Get the secrets
          if [ -n "$VAULT" ] && [ -n "$ITEM" ]; then
            # Get all fields from the item
            SECRETS=$(op item get "$ITEM" --vault "$VAULT" --format json)

            # Extract environment variables
            ENV_VARS=$(echo "$SECRETS" | jq -r '.fields[] | select(.purpose == "CONCEALED") | "export " + .label + "=" + .value')

            # Save to file if requested
            if [ -n "$ENV_FILE" ]; then
              echo "$ENV_VARS" > "$ENV_FILE"
              chmod 600 "$ENV_FILE"
            fi

            # Run the command with the secrets
            (eval "$ENV_VARS"; exec "''${COMMAND[@]}")
          else
            # Run the command with all 1Password environment variables
            op run -- "''${COMMAND[@]}"
          fi
        '';
      };
    };

    # Create a script for updating SSH authorized keys from 1Password
    home.file = lib.mkIf cfg.sshKeys.enable (lib.recursiveUpdate config.home.file {
      ".local/bin/op-update-ssh-keys" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # op-update-ssh-keys - Update SSH authorized_keys from 1Password
          # Blessed by Securitus, the Key Guardian, and Onepassus, the Vault Keeper

          set -e

          # Check if 1Password CLI is installed
          if ! command -v op &> /dev/null; then
            echo "Error: 1Password CLI is not installed"
            exit 1
          fi

          # Sign in to 1Password if needed
          if ! op account get >/dev/null 2>&1; then
            echo "Signing in to 1Password..."
            eval $(op signin)
          fi

          # Create SSH directory if it doesn't exist
          SSH_DIR="$HOME/.ssh"
          mkdir -p "$SSH_DIR"
          chmod 700 "$SSH_DIR"

          # Path to authorized_keys file
          AUTH_KEYS="$SSH_DIR/authorized_keys"

          # Create a temporary file
          TEMP_FILE=$(mktemp)
          trap "rm -f $TEMP_FILE" EXIT

          # Add header
          echo "# SSH authorized keys managed by 1Password and Home Manager" > "$TEMP_FILE"
          echo "# Last updated: $(date)" >> "$TEMP_FILE"
          echo "# DO NOT EDIT THIS FILE MANUALLY - Your changes will be overwritten" >> "$TEMP_FILE"
          echo "" >> "$TEMP_FILE"

          # Get keys from 1Password using secret references
          ${lib.concatMapStringsSep "\n" (reference: ''
            echo "# Key from 1Password reference: ${reference}" >> "$TEMP_FILE"
            op read "${reference}" >> "$TEMP_FILE" 2>/dev/null || \
              echo "Warning: Could not retrieve key from reference '${reference}'" >&2
            echo "" >> "$TEMP_FILE"
          '') cfg.sshKeys.secretReferences}

          # Check if we got any keys
          if [ $(grep -v '^#' "$TEMP_FILE" | grep -v '^$' | wc -l) -eq 0 ]; then
            echo "Error: No SSH keys found in 1Password"
            exit 1
          fi

          # Move the temporary file to authorized_keys
          mv "$TEMP_FILE" "$AUTH_KEYS"
          chmod 600 "$AUTH_KEYS"

          echo "SSH authorized_keys updated successfully from 1Password!"
        '';
      };
    });

    # Set up systemd user timer for updating SSH keys
    systemd.user.services = lib.mkIf cfg.sshKeys.enable {
      op-update-ssh-keys = {
        Unit = {
          Description = "Update SSH authorized_keys from 1Password";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "%h/.local/bin/op-update-ssh-keys";
        };
      };
    };

    systemd.user.timers = lib.mkIf cfg.sshKeys.enable {
      op-update-ssh-keys = {
        Unit = {
          Description = "Periodically update SSH authorized_keys from 1Password";
        };
        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = cfg.sshKeys.updateInterval;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };

    # Add shell integration
    programs.bash.initExtra = lib.mkIf cfg.enable ''
      # 1Password integration
      if [ -d "$HOME/.config/op-secrets" ]; then
        for file in "$HOME/.config/op-secrets/"*.env; do
          if [ -f "$file" ]; then
            source "$file"
          fi
        done
      fi

      # 1Password CLI completion
      if command -v op &>/dev/null; then
        eval "$(op completion bash)"
      fi
    '';

    # Add a command to update SSH keys on login
    home.activation = lib.mkIf cfg.sshKeys.enable {
      updateSshKeysFromOnePassword = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash $VERBOSE_ARG $HOME/.local/bin/op-update-ssh-keys || true
      '';
    };

    programs.zsh.initExtra = lib.mkIf cfg.enable ''
      # 1Password integration
      if [ -d "$HOME/.config/op-secrets" ]; then
        for file in "$HOME/.config/op-secrets/"*.env; do
          if [ -f "$file" ]; then
            source "$file"
          fi
        done
      fi

      # 1Password CLI completion
      if command -v op &>/dev/null; then
        eval "$(op completion zsh)"
      fi
    '';
  };
}
