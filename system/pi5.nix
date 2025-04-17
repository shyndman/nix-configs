
{ config, pkgs, lib, ... }:

{
  config = {
    # Set the correct architecture for Raspberry Pi 5
    nixpkgs.hostPlatform = "aarch64-linux";

    # By the divine wisdom of Shellus, the Command Interpreter:

    # Make Zsh available system-wide
    environment.shells = [ pkgs.zsh ];

    # Set the default shell for the vantron user
    users.users.vantron = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "gpio" "i2c" "spi" "video" ];
      # Note: Other user settings like home directory, groups, etc.
      # should be defined in your NixOS configuration
    };

    # Install system-wide packages that complement Zsh
    environment.systemPackages = with pkgs; [
      # Core utilities that enhance the shell experience
      bat       # Better cat
      eza       # Better ls
      fd        # Better find
      ripgrep   # Better grep
      fzf       # Fuzzy finder
      zoxide    # Better cd

      # Additional useful tools
      btop      # Process viewer (replacing htop)
      ncdu      # Disk usage analyzer
      trash-cli # Safer alternative to rm
      
      # Pi-specific tools
      i2c-tools
      usbutils
      pciutils
      lshw
      raspberrypi-tools
      
      # Network tools
      iw
      wirelesstools
      iperf3
      mtr
      nmap
      
      # System monitoring
      sysstat
      iotop
      glances
    ];

    # System-wide Zsh configuration (minimal, as most customization happens in Home Manager)
    programs.zsh = {
      enable = true;

      # Basic system-wide settings
      enableCompletion = true;
    };
    
    # Hardware-specific settings for Raspberry Pi 5
    hardware = {
      enableRedistributableFirmware = true;
      
      # Enable I2C, SPI, and GPIO for sensors and peripherals
      i2c.enable = true;
      spi.enable = true;
      
      # Enable Bluetooth
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
    
    # Enable and configure services needed for the van
    services = {
      # SSH for remote access
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
      
      # Network Time Protocol for accurate time
      timesyncd.enable = true;
      
      # Automatic updates
      auto-upgrade = {
        enable = true;
        allowReboot = false;
        dates = "04:00";
      };
      
      # Log rotation
      logrotate = {
        enable = true;
        extraConfig = ''
          compress
          delaycompress
          notifempty
          rotate 7
          daily
        '';
      };
    };

    # Enable Tailscale with 1Password auth key
    system.tailscale.enable = true;
    modules.onepassword.secrets."tailscale/auth-key" = {
      vault = "Tailscale";
      item = "auth-key";
    };

    # Note: Ensure firewall allows UDP port 41641 for Tailscale
    # This must be configured manually on the base OS

    # Pi-specific services
    systemd.services = {
      # System monitor service
      pi-monitor = {
        enable = true;
        description = "Raspberry Pi System Monitor";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getBin pkgs.bash}/bin/bash -c 'while true; do ${lib.getBin pkgs.coreutils}/bin/date; ${lib.getBin pkgs.procps}/bin/free -h; sleep 60; done'";
          Restart = "always";
          RestartSec = "10";
        };
        wantedBy = [ "system-manager.target" ];
      };
      
      # Van-specific monitoring service
      van-monitor = {
        enable = true;
        description = "Van System Monitor";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getBin pkgs.bash}/bin/bash -c 'while true; do echo \"Van systems check: $(date)\"; ${lib.getBin pkgs.coreutils}/bin/cat /sys/class/thermal/thermal_zone0/temp | awk \"{printf \\\"CPU Temp: %.1f°C\\n\\\", \$1/1000}\"; sleep 300; done'";
          Restart = "always";
          RestartSec = "10";
        };
        wantedBy = [ "system-manager.target" ];
      };
    };
    
    # Power management settings
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "ondemand";
    };
    
    # Network configuration
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ]; # SSH, HTTP, HTTPS
        allowedUDPPorts = [ 53 123 ]; # DNS, NTP
      };
      
      # Wireless configuration
      wireless = {
        enable = true;
        networks = {
          "VanWiFi" = {
            psk = ""; # Will be set via environment variable
            priority = 100;
          };
          "VanHotspot" = {
            psk = ""; # Will be set via environment variable
            priority = 90;
          };
        };
      };
    };
    
    # Boot settings
    boot = {
      kernelParams = [
        "console=ttyAMA0,115200"
        "console=tty1"
        "cma=64M"
      ];
      
      # Enable watchdog to automatically reboot on hang
      kernelModules = [ "bcm2835_wdt" ];
      extraModprobeConfig = ''
        options bcm2835_wdt heartbeat=14 nowayout=1
      '';
    };
    
    # System-wide environment variables
    environment.variables = {
      EDITOR = "micro";
      VISUAL = "micro";
      TERM = "xterm-256color";
    };
  };
}
</PlandexWhole
