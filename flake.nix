{
  description = "A better way of scrolling, for mice";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./default.nix { };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/defter-scrolling";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3.pkgs.evdev
            python3.pkgs.pyudev
          ];
        };
      }
    ) // {
      # NixOS module
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.services.defter-scrolling;
          pkg = pkgs.callPackage ./default.nix { };
        in
        {
          options.services.defter-scrolling = {
            enable = mkEnableOption "defter-scrolling, a better way of scrolling for mice";

            package = mkOption {
              type = types.package;
              default = pkg;
              description = "The defter-scrolling package to use";
            };

            settings = {
              activationButtons = mkOption {
                type = types.listOf types.str;
                default = [ "BTN_FORWARD" "forward" "back" "middle" "right" ];
                description = "Mouse buttons that can activate scrolling (in order of preference)";
              };

              scrollSpeed = mkOption {
                type = types.float;
                default = 22.0;
                description = "Scroll speed multiplier";
              };

              invertScroll = mkOption {
                type = types.bool;
                default = false;
                description = "Invert scroll direction (true = page scrolling, false = view scrolling)";
              };

              dragSlop = mkOption {
                type = types.float;
                default = 4.0;
                description = "How far (in pixels) must be dragged before it's considered an intentional scroll";
              };

              axisDecisionThreshold = mkOption {
                type = types.float;
                default = 13.0;
                description = "The threshold within which it can switch axis without making a commitment";
              };

              accumulatorVectorLimit = mkOption {
                type = types.float;
                default = 5.0;
                description = "The limit on the length of the accumulator vector";
              };

              axisBreakMaxJump = mkOption {
                type = types.float;
                default = 0.0;
                description = "How far we can jump back towards the actual position of the mouse when biaxial scrolling starts";
              };
            };
          };

          config = mkIf cfg.enable {
            systemd.services.defter-scrolling = {
              description = "A better way of scrolling, for mice";
              after = [ "multi-user.target" ];
              wantedBy = [ "multi-user.target" ];
              documentation = [ "https://github.com/makoConstruct/middle-good-scrolling" ];

              serviceConfig = {
                Type = "simple";
                ExecStart = "${cfg.package}/bin/defter-scrolling";
                Restart = "on-failure";
                RestartSec = "5s";

                # Security hardening
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                ReadWritePaths = [ "/dev/input" "/dev/uinput" ];
              };
            };

            environment.etc."defter-scrolling.conf".text = ''
              [Settings]
              activation_buttons = ${concatStringsSep ", " cfg.settings.activationButtons}
              scroll_speed = ${toString cfg.settings.scrollSpeed}
              invert_scroll = ${if cfg.settings.invertScroll then "true" else "false"}
              drag_slop = ${toString cfg.settings.dragSlop}
              axis_decision_threshold = ${toString cfg.settings.axisDecisionThreshold}
              accumulator_vector_limit = ${toString cfg.settings.accumulatorVectorLimit}
              axis_break_max_jump = ${toString cfg.settings.axisBreakMaxJump}
              enable = true
            '';
          };
        };
    };
}
