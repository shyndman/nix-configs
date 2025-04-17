# Docker module for Home Manager
# This module configures Docker CLI tools and aliases

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.docker;
in {
  options.modules.docker = {
    enable = mkEnableOption "Docker configuration";
    
    compose = {
      enable = mkEnableOption "Docker Compose";
      version = mkOption {
        type = types.str;
        default = "v2";
        description = "Docker Compose version (v1 or v2)";
      };
    };
    
    tools = {
      enable = mkEnableOption "Docker tools";
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      docker
      
      # Docker Compose
      (if cfg.compose.enable then
        (if cfg.compose.version == "v1" then docker-compose
         else docker-compose)
       else null)
      
      # Additional Docker tools
      (if cfg.tools.enable then [
        lazydocker
        dive
        ctop
      ] else [])
    ];
    
    programs.zsh = {
      shellAliases = mkIf config.programs.zsh.enable {
        # Docker aliases
        d = "docker";
        dc = "docker-compose";
        dps = "docker ps";
        dpsa = "docker ps -a";
        di = "docker images";
        dex = "docker exec -it";
        dlog = "docker logs -f";
        
        # Docker Compose aliases
        dcu = "docker-compose up -d";
        dcd = "docker-compose down";
        dcr = "docker-compose restart";
        dcl = "docker-compose logs -f";
        
        # Docker cleanup
        dprune = "docker system prune -af";
        dclean = "docker container prune -f";
        diclean = "docker image prune -af";
        dvolclean = "docker volume prune -f";
      };
    };
    
    home.file.".docker/config.json".text = mkIf (cfg.enable) ''
      {
        "experimental": "enabled",
        "features": {
          "buildkit": true
        }
      }
    '';
  };
}
