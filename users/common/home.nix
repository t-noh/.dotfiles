{ pkgs, lib, config, ... }:
let
  rootdir = ./../..;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  imports = [ ./firefox.nix ];

  home = {
    stateVersion = "26.05";
    packages = pkgs.callPackage ./packages.nix {};
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;
  # disable man here because it collides with the host's man
  programs.man.enable = false;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile (rootdir + "/.bashrc") + ''
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.bash"
        source "$(fzf-share)/completion.bash"
      fi

      # hello for testing
      # :help vimtex-faq-zathura-macos
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

    '' + lib.optionalString pkgs.stdenv.isDarwin ''
      # Issue: https://discourse.nixos.org/t/brew-not-on-path-on-m1-mac/26770/4
      # make sure brew is on the path for M1
      if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';
    sessionVariables = {
      MANPAGER="nvim +Man!";
      LC_COLLATE = "C";
      LC_CTYE = "C.UTF-8";
    };
  };
  # home.file.".bashrc".source = rootdir + "/.bashrc";
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
    '';
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    historyWidget.command = "";
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/tmux";

  programs.alacritty.enable = true;
  xdg.configFile."alacritty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/alacritty";

  programs.neovim = {
    enable = true;
    package = pkgs.neovim; # nightly via neovim-nightly overlay
    sideloadInitLua = true;
    viAlias = false;
    vimAlias = false;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    defaultEditor = true;

    # extraConfig = '' '';

    extraPackages = with pkgs; [
      gnumake
      luajitPackages.tree-sitter-cli
      luajitPackages.luarocks

      # lua
      lua-language-server
      stylua

      # C/C++
      clang-tools
      cmake-language-server

      # Rust
      rust-analyzer
      rustfmt
      clippy

      # bash
      bash-language-server
      shfmt
      shellcheck

      # python3
      pyright
      black
      isort
      python3Packages.flake8

      # latex
      texlab
      proselint
      # texlive do not provide full dependencies so nix follows.
      # https://github.com/NixOS/nixpkgs/issues/56840
      python3Packages.pygments # texlive - minted

      # nix
      nixd
      statix
      nixfmt
      alejandra

      # general writting
      # nodePackages.write-good

      # etc
      zls
      gopls
      vscode-langservers-extracted
      vim-language-server
      prettier

    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # packages only available in Linux
    ];


    # use its own plugin manager
    plugins = with pkgs.vimPlugins; [ ];
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/nvim_mini";

  # programs.zathura.enable = true;
  xdg.configFile."zathura".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/zathura";

  programs.sioyek.enable = true;

  programs.delta.enableGitIntegration = true;
  programs.git = {
    enable = true;
    settings = {
      user.name = "Taehyun Noh";
      user.email = "taehyun@utexas.edu";
      delta = {
        enable = true; # sets core.pager and interactive.diffFilter automatically
        options = {
          syntax-theme = "gruvbox-dark";
          navigate = true;
          light = false;
          line-numbers = true;
        };
      };
      aliases = {
        graph = "log --decorate --oneline --graph";
      };
      init.defaultBranch = "main";
      add.interactive.useBuiltin = false; # required for git 2.37.0
      merge.conflictStyle = "zdiff3";
      merge.tool = "nvimdiff";
      commit.verbose = true;
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      rerere.enabled = true;
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckObjects = true;
    };
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-dash
      gh-eco
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    extraOptions = [ "--group-directories-first" "--header" ];
    git = true;
    icons = "auto";
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.tealdeer.enable = true;

  programs.zellij = {
    enable = true;
  };

}
