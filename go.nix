{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    go.enable = lib.mkEnableOption "enable go devenv";
  };

  config = lib.mkIf config.go.enable {
    languages.go.enable = true;
    languages.nix.enable = true;

    git-hooks.hooks = {
      gofmt.enable = true;
      golangci-lint.enable = true;
      gotest.enable = true;
      govet.enable = true;
      revive.enable = true;
      staticcheck.enable = true;

      nixfmt-rfc-style.enable = true;
      statix.enable = true;
      deadnix.enable = true;
      commitizen.enable = true;
    };

    enterShell = ''
      echo hello from 
    '';

    outputs = {
      filesort = pkgs.buildGoModule {
        pname = "filesort";
        version = "0.1.0";

        src = ./.;

        vendorHash = null;

        meta = {
          description = "";
          homepage = "";
        };
      };
    };
  };
}
