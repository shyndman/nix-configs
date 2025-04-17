{ config, lib, pkgs, ... }:

let
  # Get the auth key from 1Password
  authKey = config.modules.onepassword.secrets."tailscale/auth-key";
in {
  options.system.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tailscale;
      description = "Tailscale package to use";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tailscale";
      description = "Directory to store Tailscale state";
    };
  };

  config = lib.mkIf config.system.tailscale.enable {
    environment.systemPackages = [ config.system.tailscale.package ];

    systemd.services.tailscale = {
      enable = true;
      description = "Tailscale VPN Service";
      after = [ "network.target" ];
      wantedBy = [ "system-manager.target" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${config.system.tailscale.package}/bin/tailscaled --state=${config.system.tailscale.stateDir}/tailscaled.state";
        ExecStartPost = "${config.system.tailscale.package}/bin/tailscale up --authkey ${authKey}";
        Restart = "always";
        RestartSec = "5s";
      };

      preStart = ''
        mkdir -p ${config.system.tailscale.stateDir}
        chmod 700 ${config.system.tailscale.stateDir}
      '';
    };
  };
}
