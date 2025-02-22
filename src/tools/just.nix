{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    devenvs.tools.just = {
      enable = lib.mkEnableOption "enable the just-generate script";
      pre-commit.enable = lib.mkEnableOption "enable the launch of pre-commit on all files in just test";
      just-content = lib.mkOption {
        default = "";
        description = "internal to contain all the justfile";
        type = lib.types.lines;
      };
      just-build = lib.mkOption {
        default = "";
        type = lib.types.lines;
        example = "cargo build";
        description = "a command to build the software, that is added to the justfile";
      };
      just-run = lib.mkOption {
        default = "";
        type = lib.types.lines;
        example = "cargo run";
        description = "a command to run the software, that is added to the justfile";
      };
      just-doc = lib.mkOption {
        default = "";
        type = lib.types.lines;
        example = "cargo doc";
        description = "a command to build the docs, that is added to the justfile";
      };
      just-test = lib.mkOption {
        default = "";
        type = lib.types.lines;
        example = "cargo test";
        description = "a command that launches the tests, that is addad to the justfile";
      };
    };
  };

  config = lib.mkIf config.devenvs.tools.just.enable {
    packages = [ pkgs.just ];

    scripts = lib.mkIf config.devenvs.global.scripts.enable {
      just-generate.exec = ''
        echo "${config.devenvs.tools.just.just-content}" > justfile
      '';
    };

    devenvs.tools.just.just-test =
      if config.devenvs.tools.just.pre-commit.enable then "  pre-commit run --all-files" else "";

    devenvs.tools.just.just-content = ''
      #this justfile is generated

      default:
        just --list

      ${if config.devenvs.tools.just.just-build != "" then "build:" else ""}
      ${config.devenvs.tools.just.just-build}

      ${
        if (config.devenvs.tools.just.just-run != "") then
          "run:${if config.devenvs.just.just-build != "" then " build" else ""}"
        else
          ""
      }
      ${config.devenvs.tools.just.just-run}

      ${
        if (config.devenvs.tools.just.just-test != "") then
          "tests:${if config.devenvs.tools.just.just-build != "" then " build" else ""}"
        else
          ""
      }
      ${config.devenvs.tools.just.just-test}

      ${if config.devenvs.tools.just.just-doc != "" then "docs:" else ""}
      ${config.devenvs.tools.just.just-doc}

      all: ${if config.devenvs.tools.just.just-build != "" then "build" else ""} ${
        if config.devenvs.tools.just.just-test != "" then "tests" else ""
      } ${if config.devenvs.tools.just.just-doc != "" then "docs" else ""}
    '';
  };
}
