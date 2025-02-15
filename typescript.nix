{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    ts = {
      enable = lib.mkEnableOption "enable ts devenv";
      prettier.enable = lib.mkEnableOption "enable prettier hook";
      biome.enable = lib.mkEnableOption "enable biome hook";
    };
  };

  config = lib.mkIf config.ts.enable {
    enterTest = ''
      jest
    '';

    languages = {
      javascript = {
        enable = true;
        npm.enable = true;
        npm.install.enable = true;
        package = pkgs.nodejs_latest;
      };
      typescript.enable = true;
    };

    scripts = {
      tests.exec = config.enterTest;
    };

    git-hooks.hooks =
      {
        eslint.enable = true;
      }
      // lib.attrsets.optionalAttrs config.ts.biome.enable {
        biome.enable = true;
      }
      // lib.attrsets.optionalAttrs config.ts.prettier.enable {
        prettier.enable = true;
      };
  };
}
