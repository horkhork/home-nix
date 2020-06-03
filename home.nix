{ pkgs, ... }:

let
  homedir = builtins.getEnv "HOME";
  workspace = homedir + "/workspace";

in {
  home.stateVersion = "20.03";
  home.language.base = "en_US.UTF-8";
  home.packages = [
    pkgs.asciidoc
    pkgs.curl
    pkgs.file
    pkgs.gcc
    pkgs.go
    pkgs.htop
    pkgs.httpie
    pkgs.k6
    pkgs.nerdfonts
    pkgs.niv # https://github.com/nmattia/niv
    pkgs.pandoc
    pkgs.pv
    pkgs.python3
    pkgs.ripgrep
    pkgs.terraform
    pkgs.traceroute
    pkgs.unzip
    pkgs.vault
    pkgs.wget
    pkgs.zsh-powerlevel10k
  ];

  home.sessionVariables = {
    NIX_PATH = "${homedir}/.nix-defexpr/channels";
    #NIX_PROFILES = "/nix/var/nix/profiles/default ${homedir}/.nix-profile";
    NIX_PROFILES = "${homedir}/.nix-profile";
    PATH = "${homedir}/.nix-profile/bin:$PATH";
    SHELL = "${homedir}/.nix-profile/bin/zsh";
    LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
    POWERLEVEL9K_INSTANT_PROMPT = "quiet";
    #LESSCLOSE = "/usr/bin/lesspipe %s %s";
    #LESSOPEN =| "/usr/bin/lesspipe %s";
    #NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    #NSS_DEFAULT_DB_TYPE = "sql";
  };

  programs = {
    bat.enable = true;

    broot = {
      enable = true;
      enableZshIntegration = true;
    };

    command-not-found.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      userName = "Steve Sosik";
      userEmail = "ssosik@gmail.com";
      aliases = {
        lg = "log --graph --oneline --decorate --all";
        com = "commit -v";
        fet = "fetch -v";
        co = "!git checkout $(git branch | fzf-tmux -r 50)";
        a = "add -p";
        pu = "pull --rebase=true origin master";
        ignore = "update-index --skip-worktree";
        unignore = "update-index --no-skip-worktree";
        hide = "update-index --assume-unchanged";
        unhide = "update-index --no-assume-unchanged";
        showremote = "!git for-each-ref --format=\"%(upstream:short)\" \"$(git symbolic-ref -q HEAD)\"";
        prune-merged = "!git branch -d $(git branch --merged | grep -v '* master')";
      };
      extraConfig = {
        core = {
          editor = "vim";
          fileMode = "false";
          filemode = "false";
        };
        push = {
          default = "simple";
        };
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        pager = {
          branch = "false";
        };
        credential = {
          helper = "cache --timeout=43200";
        };
      };
    };

    gpg.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    jq.enable = true;
    lesspipe.enable = true;
    readline.enable = true;

    #keychain = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    taskwarrior = {
      enable = true;
      colorTheme = "dark-blue-256";
      dataLocation = "$HOME/.task";
      config = {
        uda.totalactivetime.type = "duration";
        uda.totalactivetime.label = "Total active time";
        report.list.labels = [ "ID" "Active" "Age" "TimeSpent" "D" "P" "Project" "Tags" "R" "Sch" "Due" "Until" "Description" "Urg" ];
        report.list.columns = [ "id" "start.age" "entry.age" "totalactivetime" "depends.indicator" "priority" "project" "tags" "recur.indicator" "scheduled.countdown" "due" "until.remaining" "description.count" "urgency" ];
      };
    };

    tmux = {
      enable = true;
      extraConfig = ''
        set -g default-shell /home/ssosik/.nix-profile/bin/zsh
        set -g default-terminal "xterm-256color"
      '';
      keyMode = "vi";
    };

    vim = {
      enable = true;
      extraConfig = builtins.readFile "${homedir}/.config/nixpkgs/dot.vimrc";
      #settings = {
      #   relativenumber = true;
      #   number = true;
      #};
      plugins = [
        pkgs.vimPlugins.Jenkinsfile-vim-syntax
        pkgs.vimPlugins.ale
        pkgs.vimPlugins.ansible-vim
        pkgs.vimPlugins.calendar-vim
        pkgs.vimPlugins.direnv-vim
        pkgs.vimPlugins.emmet-vim
        pkgs.vimPlugins.fzf-vim
        pkgs.vimPlugins.goyo-vim
        pkgs.vimPlugins.jedi-vim
        pkgs.vimPlugins.jq-vim
        pkgs.vimPlugins.molokai
        pkgs.vimPlugins.nerdcommenter
        pkgs.vimPlugins.nerdtree
        pkgs.vimPlugins.nerdtree-git-plugin
        pkgs.vimPlugins.rust-vim
        pkgs.vimPlugins.tabular
        pkgs.vimPlugins.vim-airline
        pkgs.vimPlugins.vim-airline-themes
        pkgs.vimPlugins.vim-devicons
        pkgs.vimPlugins.vim-eunuch
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.vim-gitgutter
        pkgs.vimPlugins.vim-go
        pkgs.vimPlugins.vim-markdown
        pkgs.vimPlugins.vim-multiple-cursors
        pkgs.vimPlugins.vim-nix
        pkgs.vimPlugins.vim-plug
        pkgs.vimPlugins.vim-repeat
        pkgs.vimPlugins.vim-sensible
        pkgs.vimPlugins.vim-speeddating
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-terraform
        pkgs.vimPlugins.vim-unimpaired
      ];
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      history = {
        extended = true;
        save = 50000;
        share = true;
        size = 50000;
      };
      oh-my-zsh = {
        enable = true;
            plugins = [ "git" "history" "taskwarrior" "virtualenv" ]; # "tmuxinator" "ssh-agent"
            theme = "zsh-powerlevel10k/powerlevel10k";
            custom = "${pkgs.zsh-powerlevel10k}/share/";
      };
    };

  }; # End programs

  home.file.".p10k.zsh".text = builtins.readFile "${homedir}/.config/nixpkgs/dot.p10k.zsh";
  home.file.".zshrc".text = builtins.readFile "${homedir}/.config/nixpkgs/dot.zshrc";
  home.file.".envrc".text = ''
  '';

}
