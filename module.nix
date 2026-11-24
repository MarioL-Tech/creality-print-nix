self: { config, lib, pkgs, ... }:
let
  cfg = config.programs.creality-print;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.programs.creality-print = {
    enable = lib.mkEnableOption "Creality Print";
    useX11 = lib.mkEnableOption "the X11 backend for Creality Print (requires X11 or XWayland)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = system == "x86_64-linux";
      message = "Creality Print is only available on x86_64-linux.";
    }];
    environment.systemPackages = lib.optionals (system == "x86_64-linux") [
      (self.packages.${system}.default.override { inherit (cfg) useX11; })
    ];
  };
}
