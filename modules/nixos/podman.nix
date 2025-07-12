{
  config,
  lib,
  pkgs,
  ...
}:

with lib; 

let cfg = config.modules.podman;

in {
  options.modules.podman.enable = mkEnableOption "enable podman";

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--filter=until=24h"
            "--filter=label!=important"
          ];
        };
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
