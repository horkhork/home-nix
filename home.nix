{ config, pkgs, ... }:

with import <nixpkgs> {};
#with builtins;
#with lib;
#with import <home-manager/modules/lib/dag.nix> { inherit lib; };

#let
#dotfiles = stdenv.mkDerivation {
#   name = "dotfiles";
#   src = fetchFromGitHub {
#      owner = "horkhork";
#      repo = "dotfiles";
#      rev = "master";
#      sha256 = "ce6d7aa7a26a6b1edf6ab5261c2f982fff2d57fd2e861fb02cc4c21d5ddd9963";
#   };
#   installPhase = ''
#     mkdir -p $out
#   '';
#};
#in {

let
  homedir = builtins.getEnv "HOME";
  workspace = homedir + "/workspace";

  createP4Client = pkgs.writeShellScriptBin "createP4Client" ''
name=$1 # client name to create
template=$2 # client to use as a template
  '';

  vaultWorkspace = stdenv.mkDerivation {
    name = "fetch-vault-repo";
    src = builtins.fetchGit {
      url = "ssh://git@git.source.akamai.com:7999/sources/vault.git";
      rev = "4c647e4a9931cff3614e779203835285212e409e";
    };
    #buildInputs = [ homedir ];
    buildPhase = ''
      echo BUILD OUT $out $src ${workspace} foo
    '';
    installPhase = ''
      echo INSTALL OUT $out
      mkdir -p $out
    '';
  };

  bartComponents = [
    {
      name = "vault";
      version = "1.2.3-7.0";
      buildOS = "alsi9-lite-lib64";
    }
  ];

in {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "19.09";

  home.language.base = "en_US.UTF-8";

  home.sessionVariables = {
    LESSCLOSE = "/usr/bin/lesspipe %s %s";
    #LESSOPEN =| "/usr/bin/lesspipe %s";
    NIX_PATH = "/home/ssosik/.nix-defexpr/channels";
    NIX_PROFILES = "/nix/var/nix/profiles/default /home/ssosik/.nix-profile";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NSS_DEFAULT_DB_TYPE = "sql";
    PATH = "/home/ssosik/bin:/home/ssosik/.nix-profile/bin:$PATH";
    SHELL = "/home/ssosik/.nix-profile/bin/zsh";
    LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
  };

  home.packages = [
    pkgs.asciidoc
    pkgs.curl
    pkgs.gcc
    pkgs.go
    pkgs.httpie
    pkgs.k6
    pkgs.pandoc
    pkgs.pv
    pkgs.python3
    pkgs.ripgrep
    pkgs.traceroute
    pkgs.unzip
    pkgs.wget
    pkgs.zsh-powerlevel10k
    pkgs.nerdfonts
    pkgs.terraform
    pkgs.vault
    vaultWorkspace
  ];

  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.command-not-found.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Steve Sosik";
    userEmail = "ssosik@akamai.com";
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

  #programs.gpg.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #programs.info.enable = true;

  programs.jq.enable = true;

  #programs.keychain = {
  #  enable = true;
  #  enableZshIntegration = true;
  #};

  #programs.lesspipe.enable = true;

  #programs.newsboat = {
  #  enable = true;
  #};

  #programs.readline.enable = true;

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*.akamai.com" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "*.akamaitechnologies.com" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "172.25.*" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "172.26.*" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "*.tn.akamai.com" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "*.qa.akamai.com" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "198.18.*" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };
      "198.19.*" = {
        extraOptions = {
          HostKeyAlgorithms = "+ssh-dss";
          User = "root";
          ForwardX11 = "no";
          ForwardAgent = "no";
          StrictHostKeyChecking = "no";
        };
      };

      "*.vn.akamai.com" = {
        extraOptions = {
          ProxyCommand = "ssh root@$VRT_GW nc %h %p";
          User = "root";
        };
      };
      "100.80.*" = {
        extraOptions = {
          ProxyCommand = "ssh root@$VRT_GW nc %h %p";
          User = "root";
        };
      };
    };

    #matchBlocks = {
    #  "git.source.akamai.com" = {
    #    identityFile = "/home/ssosik/.ssh/2020-01-10";
    #    extraOptions = { StrictHostKeyChecking = "No"; };
    #  };
    #  "p4.source.akamai.com" = {
    #    identityFile = "/home/ssosik/.ssh/2020-01-10";
    #    extraOptions = { StrictHostKeyChecking = "No"; };
    #  };
    #  "p4.ops.akamai.com" = {
    #    identityFile = "/home/ssosik/.ssh/2020-01-10";
    #    extraOptions = { StrictHostKeyChecking = "No"; };
    #  };
    #};
  };
  home.file.".ssh/rc".text = ''
if [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi
'';

  home.file.".envrc".text = ''
    export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
    export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
    #PATH_add /home/ssosik/.local/bin
    #PATH_add $HOME/bin
    #PATH_add $HOME/go/bin
    #PATH_add /usr/local/go/bin
    #export GOPATH=$HOME/gocode
    #export GOROOT=$HOME/go
    #PATH_add $HOME/.cargo/bin
    export W="$HOME/workspace"
    export VAULT_CLIENT_CERT=$HOME/.certs/$USER-testnet.crt
    export VAULT_CLIENT_KEY=$HOME/.certs/$USER-testnet.key
    export VAULT_CACERT=$HOME/.certs/nss1-canonical_ca_roots.pem
    export CLIENT_CERT=$HOME/.certs/$USER.crt
    export CLIENT_KEY=$HOME/.certs/$USER.key
    export CACERT=$HOME/.certs/root_certs.pem
    '';

  #programs.starship = {
  #  enable = true;
  #  #enableZshIntegration = true;
  #  enableBashIntegration = true;
  #};

  programs.taskwarrior = {
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

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-shell /home/ssosik/.nix-profile/bin/zsh
      set -g default-terminal "xterm-256color"
      #set -g update-environment "DISPLAY SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"
      set-environment -g 'SSH_AUTH_SOCK' ~/.ssh/ssh_auth_sock
      set -g update-environment "SSH_AUTH_SOCK"
    '';
    keyMode = "vi";
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile "/home/ssosik/.config/nixpkgs/vimrc";
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

  home.file.".config/zsh/.p10k.zsh".text = builtins.readFile "/home/ssosik/.config/nixpkgs/p10k.cfg";

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";
    history = {
      extended = true;
      save = 100000;
      share = true;
      size = 100000;
    };
    localVariables = {
      ZSH_TMUX_ITERM2 = true;
      POWERLEVEL9K_MODE = "nerdfont-complete";
      COMPLETION_WAITING_DOTS = true;
      ZSH_CUSTOM = "${pkgs.zsh-powerlevel9k}/share/";
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
      #SSH_AUTH_SOCK = ".ssh/ssh_auth_sock";
    };
    envExtra = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #initExtraBeforeCompInit = "source ${homedir}/.cbe-dev.sh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "history" "taskwarrior" "tmuxinator" "virtualenv" "ssh-agent" ]; # "zsh-autosuggestions" "tmux"
    };
  };

  #services.gpg-agent = {
  #  enable = true;
  #};

  #services.lorri.enable = true;

}
