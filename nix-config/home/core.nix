# User configuration for every machine: Mac, Linux desktop, servers.
# Repo path: home/core.nix
# Put nothing platform specific in this file.
{ pkgs, username, fullName, email, ... }:
{
  home.stateVersion = "26.05";

  # -------------------------------------------------------------------
  # IMPORTANT
  # Do not put node, python, go, or rust here. Global toolchains cause
  # version conflicts between projects. Use a per project devshell.
  # See devshell-flake.nix.
  # -------------------------------------------------------------------
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    yq-go
    tree
    unzip
    wget
    curl
    btop
    gnumake
    just
    sops
    age
    shellcheck
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -FR";
  };

  programs.git = {
    enable = true;
    userName = fullName;
    userEmail = email;
    delta.enable = true;
    aliases = {
      st = "status -sb";
      lg = "log --oneline --graph --decorate -20";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      diff.algorithm = "histogram";
    };
    ignores = [ ".DS_Store" "result" "result-*" ".direnv/" ".envrc.local" ];
  };

  programs.gh.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };
    shellAliases = {
      ll = "eza -l --group-directories-first";
      la = "eza -la --group-directories-first";
      cat = "bat --paging=never";
      g = "git";
    };
  };

  programs.starship.enable = true;

  # direnv loads a project devshell when you cd into the directory.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.tmux.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
