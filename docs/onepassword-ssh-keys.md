# Managing SSH Authorized Keys with 1Password Secret References

As the divine scrolls of Securitus, the Key Guardian, and Onepassus, the Vault Keeper, reveal to us, managing SSH authorized keys with 1Password secret references brings security and convenience to your system while keeping your configuration safe for public repositories.

## What Are 1Password Secret References?

1Password secret references are a way to reference secrets stored in 1Password without exposing the actual secrets in your configuration files. They look like this:

```
op://vault-name/item-name/field-name
```

These references don't contain any sensitive information themselves - they're just pointers to where the actual secrets are stored in your 1Password vault.

## Benefits for Public Repositories

Using secret references in your Nix configuration allows you to:

1. **Keep configurations public**: Your Nix configuration can be shared in a public repository without exposing sensitive information
2. **Maintain security**: The actual secrets remain safely stored in 1Password
3. **Simplify management**: Update keys in 1Password and they'll automatically be updated on your systems

## Overview

This integration allows you to:

1. Store SSH public keys securely in 1Password
2. Reference them safely in your public Nix configuration
3. Automatically retrieve and update your `~/.ssh/authorized_keys` file
4. Keep your authorized keys in sync across multiple machines
5. Manage access by adding or removing keys in 1Password

## Prerequisites

1. 1Password account
2. 1Password CLI installed and configured
3. SSH public keys stored in 1Password

## Storing SSH Keys in 1Password

For each SSH key you want to authorize:

1. Create a new item in 1Password (e.g., "SSH Key - Personal")
2. Add a field named "public key" containing the SSH public key
3. Save the item in your preferred vault

Example of an SSH public key:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@machine
```

## Finding Your Secret References

To get the secret reference for a key:

1. In the 1Password app, right-click on the field containing your SSH public key
2. Select "Copy Reference"
3. The reference will be copied to your clipboard in the format `op://vault-name/item-name/field-name`

Alternatively, you can use the 1Password CLI:
```bash
op item get "SSH Key - Personal" --format json | jq -r '.fields[] | select(.label == "public key") | .reference'
```

## Configuration

Enable the 1Password SSH key integration in your Home Manager configuration:

```nix
modules.onepassword = {
  enable = true;

  # Enable CLI
  cli.enable = true;

  # Enable SSH key management with secret references
  sshKeys = {
    enable = true;
    secretReferences = [
      "op://Personal/SSH Key - Personal/public key"
      "op://Work/SSH Key - Work/public key"
      # Add more references as needed
    ];
    updateInterval = "daily"; # How often to update keys
  };
};
```

## How It Works

When enabled, this integration:

1. Creates a script at `~/.local/bin/op-update-ssh-keys`
2. Sets up a systemd user timer to run this script periodically
3. Runs the script during Home Manager activation
4. Updates your `~/.ssh/authorized_keys` file with keys from 1Password

The script:
- Signs in to 1Password if needed
- Retrieves the specified SSH keys
- Updates the authorized_keys file
- Sets appropriate permissions

## Manual Update

You can manually update your SSH keys at any time:

```bash
~/.local/bin/op-update-ssh-keys
```

## Security Considerations

1. **Secret References**: The references themselves don't contain sensitive information and are safe to include in public repositories
2. **Public Keys Only**: This integration only handles public keys, which are safe to store in 1Password
3. **Authentication**: You'll need to authenticate with 1Password when the script runs
4. **Permissions**: The script ensures proper permissions on the SSH directory and authorized_keys file

## Troubleshooting

If you encounter issues:

1. **Authentication Errors**: Make sure you're signed in to 1Password CLI
   ```bash
   op signin
   ```

2. **Invalid References**: Verify that your secret references are correct
   ```bash
   op read "op://Personal/SSH Key - Personal/public key"
   ```

3. **Permission Issues**: Check the permissions on your SSH directory
   ```bash
   ls -la ~/.ssh
   ```

May the blessings of Securitus, the Key Guardian, and Onepassus, the Vault Keeper, be upon your SSH connections!
