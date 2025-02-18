{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  options = {
    devenvs.rust.enable = lib.mkEnableOption "enable rust devenv";
    devenvs.rust.tests.enable = lib.mkEnableOption "enable nextest + test -doc";
  };

  config = lib.mkIf config.devenvs.rust.enable {
    languages.rust.enable = lib.mkIf config.devenvs.global.languages.enable true;

    git-hooks.hooks = lib.mkIf config.devenvs.global.hooks.enable {
      rustfmt.enable = true;
      taplo.enable = true;
      markdownlint.enable = true;
      yamlfmt.enable = true;
      clippy.enable = true;
      cargo-check.enable = true;
      cargo-deny = {
        enable = true;
        name = "cargo-deny";
        entry = "${pkgs.cargo-deny}/bin/cargo-deny check bans licenses sources";
        files = "\\.rs$";
        pass_filenames = false;
      };
      cargo-machete = {
        enable = true;
        name = "cargo-machete";
        entry = "${pkgs.cargo-machete}/bin/cargo-machete";
        files = "\\.rs$";
        pass_filenames = false;
      };
      cargo-audit = {
        enable = true;
        name = "cargo-audit";
        entry = "${pkgs.cargo-audit}/bin/cargo-audit audit -n -d ${inputs.devenvs.inputs.advisory-db} -D warnings -D unmaintained -D unsound -D yanked"; # TODO: maybe essayer de mettre db dans une option pour pas rely on inputs
        files = "\\.rs$";
        pass_filenames = false;
      };
    };

    packages = lib.mkIf config.devenvs.global.packages.enable [
      #voir la taille des grosses deps
      pkgs.cargo-bloat
      #gerer les deps depuis le cli
      pkgs.cargo-edit
      #auto compile
      pkgs.cargo-watch
    ];

    env = lib.mkIf config.devenvs.global.env.enable {
      RUST_BACKTRACE = "1";
    };

    scripts = lib.mkIf config.devenvs.global.scripts.enable {
      docs.exec = "cargo doc";
      update.exec = "cargo update -v --recursive";

      coverage.exec = "${pkgs.cargo-tarpaulin}/bin/cargo-tarpaulin --skip-clean --out Html";
    };

    enterTest = lib.mkIf config.devenvs.global.enterTest.enable (
      lib.mkIf config.devenvs.rust.tests.enable ''
        ${pkgs.cargo-nextest}/bin/cargo-nextest nextest run
        cargo test --doc
      ''
    );
  };
}
