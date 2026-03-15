flakeSelf:

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.fennec;

  baseCss = builtins.readFile "${flakeSelf}/chrome/userChrome.css";

  userChromeCss =
    if cfg.autohide
    then builtins.replaceStrings
      [ ''/* @import url("autohide.css"); */'' ]
      [ ''@import url("autohide.css");'' ]
      baseCss
    else baseCss;
in
{
  options.programs.fennec = {
    enable = lib.mkEnableOption "Fennec Firefox theme";

    profile = lib.mkOption {
      type = lib.types.str;
      default = "default-release";
      description = "Firefox profile name to install Fennec into.";
    };

    autohide = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the autohide module (sidebar collapses when mouse leaves).";
    };

    sideberry = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the Sideberry extension via NUR. Requires NUR in your flake inputs.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.${cfg.profile} = {
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "sidebar.verticalTabs" = false;
          "sidebar.revamp" = false;
        };
        userChrome = userChromeCss;
        extensions = lib.mkIf cfg.sideberry {
          packages = [
            pkgs.nur.repos.rycee.firefox-addons.sidebery
          ];
        };
      };
    };

    home.file.".mozilla/firefox/${cfg.profile}/chrome/autohide.css" = lib.mkIf cfg.autohide {
      text = builtins.readFile "${flakeSelf}/chrome/autohide.css";
    };
  };
}
