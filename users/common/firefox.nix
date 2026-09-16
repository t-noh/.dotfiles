{ inputs, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.firefox = {
    enable = true;

    # macOS: the app comes from the homebrew cask (machines/homebrew.nix).
    # Linux: let home-manager provide it.
    package = if isDarwin then null else pkgs.firefox;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFeedbackCommands = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        # Vim keys. Its own settings (e.g. excluding docs.google.com) live in
        # the extension's storage, not here.
        "vimium-c@gdh1995.cn" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.default = {
      id = 0;
      isDefault = true;

      # Betterfox baseline.
      preConfig = builtins.readFile "${inputs.betterfox}/user.js";

      settings = {
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "extensions.pocket.enabled" = false;
        "browser.shopping.experience2023.enabled" = false;
        "browser.tabs.firefox-view" = false;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.privatebrowsing.vpnpromourl" = "";
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.showSearchTerms.enabled" = false;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;

        # --- Layout ---
        "browser.uidensity" = 1;
        "browser.toolbars.bookmarks.visibility" = "never";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "browser.download.always_ask_before_handling_new_types" = false;
        "layout.word_select.eat_space_to_next_word" = false;

        # --- Keyboard ---
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.tabs.insertAfterCurrent" = true;
        "browser.link.open_newwindow.restriction" = 0;
        "accessibility.typeaheadfind.enablesound" = false;

        # --- Betterfox overrides ---
        # "browser.search.suggest.enabled" = true;        # Google completions in the url bar
        # "permissions.default.desktop-notification" = 0; # let web apps ask to notify
        # "browser.cache.disk.enable" = true;             # keep a disk cache
      };

      search = {
        force = true;
        default = "google";
        privateDefault = "google";
        engines = {
          nix-packages = {
            name = "Nix Packages";
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@nixp" ];
          };
          nix-options = {
            name = "Nix Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@nixo" ];
          };
          home-manager-options = {
            name = "Home Manager Options";
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [
                { name = "release"; value = "master"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@hm" ];
          };
          github = {
            name = "GitHub";
            urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
            definedAliases = [ "@gh" ];
          };

          bing.metaData.hidden = true;
          ebay.metaData.hidden = true;
          amazondotcom-us.metaData.hidden = true;
        };
      };
    };
  };
}
