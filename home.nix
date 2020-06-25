{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv which dpkg ;

  homedir = builtins.getEnv "HOME";
  whoAmI = builtins.getEnv "USER";
  workspace = homedir + "/workspace";

  # TODO
  # - Create $HOME/workspace
  # - Use `workspace` command to create component workspaces
  # - Wrapper for apt
  # - Install a few Ubuntu things, including CBE and PBRA
  # - Share .zsh_history across machines

  # Provide a custom version of terraform
  terraform = stdenv.mkDerivation {
    name = "terraform-0.12.24";

    unpackPhase = "true";

    src = pkgs.fetchzip {
      url = "https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip";
      sha256 = "12hdq2c9pphipr7chdgp91k52rgla22048yhlps6ilpfv8v50467";
    };

    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/terraform $out/bin/.
    '';
  };

  vimdiary = stdenv.mkDerivation {
    name = "vimdiary";
    buildInputs = [ which pkgs.git pkgs.nix-prefetch-git ] ;
    #src = builtins.fetchGit { url = "git@github.com:horkhork/vimdiary.git"; };
    src = pkgs.fetchgit {
      url = "ssh://git@github.com/horkhork/vimdiary.git";
      leaveDotGit = true;
      deepClone = true;
      sha256 = "12hdq2c9pphipr7chdgp91k52rgla22048yhlps6ilpfv8v50467";
    };
    installPhase = ''
      export SSH_AUTH_SOCK=/home/ssosik/.ssh/ssh_auth_sock
      echo "STEVE $src $out"
      #mkdir -p $out
      #mkdir -p ${homedir}/git
      ##SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock $(which git) clone git@github.com:horkhork/vimdiary.git ${homedir}/git/
      ##SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock nix-prefetch-git --leave-dotGit --deepClone git@github.com:horkhork/vimdiary.git
    '';
  };

  # Provide various Python packages
  my-python-packages = python-packages: with python-packages; [
    requests
    #pip
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

  # Provide apt within nix to install some things
  footest = stdenv.mkDerivation {
    name = "footest";

    unpackPhase = "true";

    buildInputs = [ which dpkg ];

    installPhase = ''
      echo "STEVE $src $out"
      mkdir -p "$out/bin"
      echo "STEVE2 $(which dpkg)"
    '';
  };


in {
  home.activation = {
    ubuntuSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
set -euxo pipefail

# Install required things from apt
sudo apt-get install -y akamai-sql akamai-nsh

# Get Testnet cert generator
if [ ! -e $HOME/generate-dbattery-testnet-certificate  ] ; then
    p4 print -o generate-dbattery-testnet-certificate //projects/syscomm/tools/generate-dbattery-testnet-certificate
    ./generate-dbattery-testnet-certificate --skip-validate --pem $USER
    openssl pkey -in ${whoAmI}-testnet.pem -out ${whoAmI}-testnet.key
fi

# Get Testnet Root CA
if [ ! -e $HOME/.certs/qa-canonical_ca_roots.pem ] ; then
    p4 print -o $HOME/.certs/qa-canonical_ca_roots.pem //projects/kmi/netconfig-ssl_ca-qa-1.10/akamai/netconfig-ssl_ca-qa/etc/ssl_ca/canonical_ca_roots.pem
fi

# Install CBE
if [ ! -e /home/.docker ] ; then
    echo Installing CBE

    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo curl http://junkheap.reston.corp.akamai.com/repos/apt/gpg-key.asc | sudo apt-key add -
    sudo apt-key fingerprint 20D1FDBCD30DC9F43A89D42D30B7ADFA61BD7044

    echo "deb [arch=amd64] http://junkheap.reston.corp.akamai.com/repos/apt/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/bart_rest_api.list
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

    sudo apt-get update
    sudo apt-get install -y docker-ce portable-bart-rest-api

    sudo groupadd docker || true
    sudo usermod -aG docker $USER || true
    sudo systemctl enable docker

    sudo mkdir /home/.docker
    sudo chmod 750 /home/.docker
    cat << EOF | sudo tee /etc/docker/daemon.json
{ "experimental":true, "graph":"/home/.docker", "storage-driver": "overlay2" }
EOF

    sudo systemctl restart docker

    sudo setup_docker_certs --user $USER
fi

# Make my workspace
$DRY_RUN_CMD mkdir -p $HOME/workspace
    '';
  };

  home.stateVersion = "20.03";
  home.language.base = "en_US.UTF-8";
  home.packages = [
    footest
    pkgs.asciidoc
    pkgs.curl
    pkgs.dust # Rust implementation of 'du'
    pkgs.exa  # Rust implementation of 'ls'
    pkgs.file
    pkgs.fd   # Rust implementation of 'find'
    pkgs.skim # Rust implementation of 'find'
    pkgs.gcc
    pkgs.go
    pkgs.graphviz
    pkgs.htop
    pkgs.httpie
    pkgs.hyperfine # Rust implementation of 'time'
    pkgs.k6
    pkgs.mailutils
    pkgs.niv # https://github.com/nmattia/niv
    pkgs.pandoc
    pkgs.procs # Rust implementation of 'ps'
    pkgs.pv
    #pkgs.python3
    python-with-my-packages
    pkgs.ripgrep
    terraform #pkgs.terraform
    pkgs.timewarrior
    pkgs.tokei # Rust implementation of 'wc -l'
    pkgs.traceroute
    pkgs.tree
    pkgs.ts
    pkgs.unzip
    pkgs.vault
    pkgs.wget
    #pkgs.zenith # Rust implementation of 'top'
    pkgs.zsh-powerlevel10k
    #vimdiary
  ];

  home.sessionVariables = {
    NIX_PATH = "${homedir}/.nix-defexpr/channels";
    #NIX_PROFILES = "/nix/var/nix/profiles/default ${homedir}/.nix-profile";
    NIX_PROFILES = "${homedir}/.nix-profile";
    PATH = "${homedir}/.nix-profile/bin:${homedir}/bin:$PATH";
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

    ssh = {
      enable = true;

      matchBlocks."*.akamai.com" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."*.akamaitechnologies.com" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."172.25.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."172.26.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."*.tn.akamai.com" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."*.qa.akamai.com" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."198.18.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

      matchBlocks."198.19.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
      };

    };

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
        set -g default-shell ${homedir}/.nix-profile/bin/zsh
        set -g default-terminal "xterm-256color"
        #set-environment -g 'SSH_AUTH_SOCK' ${homedir}/.ssh/ssh_auth_sock
      '';
      keyMode = "vi";
    };

    vim = {
      enable = true;
      extraConfig = builtins.readFile "${homedir}/.config/nixpkgs/dot.vimrc";
      settings = {
         relativenumber = true;
         number = true;
      };
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
export SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock
export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
  '';
  home.file.".ssh/rc".text = ''
#!/bin/bash
if [ -S "$SSH_AUTH_SOCK" ]; then
  ln -sf $SSH_AUTH_SOCK ${homedir}/.ssh/ssh_auth_sock
fi
  '';

  services = {
    lorri = {
      enable = true;
    };
  };
}
