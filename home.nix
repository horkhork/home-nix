{ pkgs, lib, ... }:

# TODO
# - Share .zsh_history across machines
# - Get devqa automation tools working through python wrapper
# - clone ssosik_sandbox perforce repo
# - clone ssosik_scratch perforce repo
# - clone metadata perforce repo
# - double check certs (testnet) are created correctly
# - create git repo that contains all my helper bash scripts
# - get vkms-tavern-tests working
# - Get vimdiary installed and working, with git-sync
# - Set up monit to email on disk full, or when git-sync fails to run
# - Integrate with pass
# - Move home.nix into a git.sources repo

let
  inherit (pkgs) stdenv which dpkg ;

  homedir = builtins.getEnv "HOME";
  whoAmI = builtins.getEnv "USER";
  workspace = homedir + "/workspace";

  # Run the PBRA Workspace tool on for the following component versions if they
  # don't already exist, creating them under ~/workspace.
  # https://collaborate.akamai.com/confluence/display/~bailey/PBRA+Tools+Home#PBRAToolsHome-WorkspaceCommand
  akaComps = {
    vault = "1.2.3-8.0 alsi9-lite-lib64";
    vkms_terraform = "1.4 Common";
    terraform-provider-vault = "2.5.0-1.0 alsi9-lib64";
  };

  # For each of these, clone the repos under ~/workspace
  gitRepos = {
    ab-app-dev = "ssh://git@git.source.akamai.com:7999/syscommcs/ab-app-dev.git";
    akamai-cbe-dev = "ssh://git@git.source.akamai.com:7999/isuite/akamai-cbe-dev.git";
    service-mesh = "ssh://git@git.source.akamai.com:7999/syscomm/service-mesh.git";
    tavern = "https://github.com/taverntesting/tavern";
    terraform-provider-external = "https://github.com/hashicorp/terraform-provider-external";
    vault-k6-scripts = "ssh://git.source.akamai.com:7999/~ssosik/vault-k6-scripts.git";
    vimdiary = "git@github.com:horkhork/vimdiary.git";
    vkms_performance_testing = "ssh://git@git.source.akamai.com:7999/~pli/vkms_performance_testing.git";
    vkms_admin_tools = "ssh://git@git.source.akamai.com:7999/syscomm/vkms_admin_tools.git";
    vkms-tavern-intg-tests = "ssh://git@git.source.akamai.com:7999/~ssosik/vkms-tavern-intg-tests.git";
  };

  # Provide a custom version of terraform
  terraform = stdenv.mkDerivation {
    name = "terraform-0.12.28";
    unpackPhase = "true";
    src = pkgs.fetchzip {
      url = "https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip";
      sha256 = "0kzxnjkqmc6bzyrzxqhsvalwbp8ai8232bqj3kpki25kpryy4hn6";
      #url = "https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip";
      #sha256 = "00yipyhm2rsmf602amv9a21ka18h77rjpsqxbrj6f50v100l9y98";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/terraform $out/bin/.
    '';
  };

  # Provide a custom version of terraform
  atlantis = stdenv.mkDerivation {
    name = "atlantis-0.14.0";
    unpackPhase = "true";
    src = pkgs.fetchzip {
      url = "https://github.com/runatlantis/atlantis/releases/download/v0.14.0/atlantis_linux_amd64.zip";
      sha256 = "07vazkca8v0wy17irx04xhxxr53kpiliyk5fd7vlw0d16f2vs1g5";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/atlantis $out/bin/.
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

  # Perforce client
  p4 = stdenv.mkDerivation {
    name = "Perforce-client";
    unpackPhase = "true";
    buildInputs = [ dpkg ];
    src = builtins.fetchurl {
      url = "https://atlantis.akamai.com/ubuntu/akamai/bionic/perforce-client_20140929_amd64.deb";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      TMP=$(mktemp -d -p $out)
      dpkg-deb -xv $src $TMP/
      cp $TMP/usr/bin/p4 $out/bin/.
      rm -rf $TMP
    '';
  };

  # Provide apt within nix to install some things
  footest = stdenv.mkDerivation {
    name = "footest";
    unpackPhase = "true";
    buildInputs = [ which dpkg ];
    src = builtins.fetchurl {
      url = "https://atlantis.akamai.com/ubuntu/akamai/bionic/perforce-client_20140929_amd64.deb";
    };
    installPhase = ''
      echo "STEVE $src $out"
      mkdir -p "$out/bin"
      ls $src
      #$(which dpkg) --unpack --dry-run $src
      $(which dpkg-deb) -xv $src $out/
      cp $src/usr/bin/p4
      #ar x $src
      #echo "STEVE2 $(which dpkg)"
    '';
  };

  # Provide a custom shell helper tools
  helpers = stdenv.mkDerivation {
    name = "shell-helpers";
    unpackPhase = "true";
    src = builtins.fetchGit {
      url = "ssh://git@git.source.akamai.com:7999/~ssosik/shell-helpers.git";
      ref = "master";
      rev = "7984314eda81a09eb7a24db45533762a2b812b45";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/* $out/bin/.
    '';
  };

  devqa-tools = stdenv.mkDerivation {
    name = "devqa-tools";
    unpackPhase = "true";
    src = builtins.fetchGit {
      url = "ssh://git@git.source.akamai.com:7999/syscomm/devqa_tools.git";
      ref = "master";
      rev = "f5767f6a9ffce0c04ac5f0fc256df613ef66a732";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      find $src -maxdepth 1 -executable -type f -exec cp {} $out/bin/ \;
    '';
  };

  vPoint = stdenv.mkDerivation {
    name = "vpoint";
    unpackPhase = "true";
    buildInputs = [ p4 pkgs.krb5Full ] ;
    __noChroot = true;
    inherit p4;
    installPhase = ''
      mkdir -p "$out/bin"
      export SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock
      export PATH=/usr/bin/:$PATH
      export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
      echo $out
      #p4 print -q //projects/platform/vtastic/vpoint/install/install_vpoint.sh > $out/install_vpoint.sh
      p4 print -q //sandbox/ssosik/install_vpoint.sh > $out/install_vpoint.sh
      /bin/bash $out/install_vpoint.sh -C $out/
    '';
  };

  ab-app-dev = stdenv.mkDerivation {
    name = "ab-app-dev";
    unpackPhase = "true";
    src = builtins.fetchGit {
      url = "ssh://git@git.source.akamai.com:7999/syscommcs/ab-app-dev.git";
      ref = "master";
      rev = "df1b13f965e73f8c5a8d9647efc29bf7249962ad";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      find $src -maxdepth 1 -executable -type f -exec cp {} $out/bin/ \;
    '';
  };

  # Read a specific file out of a tgz under /u1/bundles
  tf-vault-provider-plugin = stdenv.mkDerivation {
    name = "tf-vault-provider-plugin";
    unpackPhase = "true";
    src = null;
    installPhase = ''
      mkdir -p "$out"
      tar -zvf /u1/bundles/projects/shared/components/alsi9/terraform-provider-vault-2.5.0-1.0/terraform-provider-vault.tgz -C $out/. --get ./terraform-provider-vault
      echo $out
      ls $out
      #cp $src/* $out/bin/.
    '';
  };

  # Create a specific P4 client
  p4-sandbox = stdenv.mkDerivation {
    name = "p4-sandbox";
    unpackPhase = "true";
    buildInputs = [ p4 ] ;
    __noChroot = true;
    inherit p4;
    installPhase = ''
      mkdir -p $out
      mkdir -p ${homedir}/workspace/sandbox
      cd ${homedir}/workspace/sandbox

      cat <<EOF > .envrc
source_up
dotenv .perforce
export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
EOF
      cat <<EOF > .perforce
P4CLIENT=ssosik_sanbox_nix

EOF

      export SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock
      export PATH=/usr/bin/:$PATH
      export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
      export P4CLIENT=ssosik_sanbox_nix

      p4 client -t ssosik_sandbox -o | p4 client -i
      #p4 client -t ssosik_sandbox -o
      #p4 client -o
      p4 sync
    '';
  };

  # Create a specific P4 client
  p4-metadata = stdenv.mkDerivation {
    name = "p4-metadata";
    buildInputs = [ which pkgs.direnv p4 ] ;
    __noChroot = true;
    #propagatedBuildInputs = [ ];
    #unpackPhase = "true";
    #installPhase = ''
    inherit p4;
    unpackPhase = ''
      mkdir -p "$out"
      echo $out
      cat <<EOF > $out/.envrc
source_up
dotenv .perforce
export P4PORT='rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true'
EOF
      cat <<EOF > $out/.perforce
P4CLIENT=ssosik_ump_metadata
EOF
      ls -latr $out
      cd $out
      #direnv allow
      echo STEVE
      export P4PORT="rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true"
      echo "p4 client -t ssosik_ump_test_depots -o | p4 client -i"
      #$(which p4) client -t ssosik_ump_test_depots -o | p4 client -i
      #$(which p4) client -t ssosik_ump_test_depots -o
      P4PORT="rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true" p4 client ssosik_ump_test_depots -o
    '';
  };

  dhallyaml = stdenv.mkDerivation {
    name = "dhall-yaml-1.2.0";
    unpackPhase = "true";
    buildInputs = [ dpkg ];
    src = builtins.fetchTarball {
      url = "https://github.com/dhall-lang/dhall-haskell/releases/download/1.33.1/dhall-yaml-1.2.0-x86_64-linux.tar.bz2";
      sha256 = "16kjb563qmj82vfaa5rfbh5mig3az41cmm4n2dgvszpaph9wr9zp";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/bin/* $out/bin/.
    '';
  };

  dhalljson = stdenv.mkDerivation {
    name = "dhall-json-1.7.0";
    unpackPhase = "true";
    buildInputs = [ dpkg ];
    src = builtins.fetchTarball {
      url = "https://github.com/dhall-lang/dhall-haskell/releases/download/1.33.1/dhall-json-1.7.0-x86_64-linux.tar.bz2";
      sha256 = "1kb4ma99nn8mqzayk2fyb0l374jqsns664690xg5a0krpfhmclgr";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/bin/* $out/bin/.
    '';
  };

  dhall = stdenv.mkDerivation {
    name = "dhall-1.33.1";
    unpackPhase = "true";
    buildInputs = [ dpkg ];
    src = builtins.fetchTarball {
      url = "https://github.com/dhall-lang/dhall-haskell/releases/download/1.33.1/dhall-1.33.1-x86_64-linux.tar.bz2";
      sha256 = "19z3zvy4rgs12kd7n97mv9y53jyfs8096k1lrcxm31hjglshms9l";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      cp $src/bin/* $out/bin/.
    '';
  };

  # Provide a newer version of glow https://github.com/charmbracelet/glow
  glow = stdenv.mkDerivation {
    name = "glow-1.0.2";
    unpackPhase = "true";
    src = builtins.fetchurl {
      url = "https://github.com/charmbracelet/glow/releases/download/v1.0.2/glow_1.0.2_linux_x86_64.tar.gz";
      #sha256 = "1wws3wvpbxgdlpgrpzh5f51bcb0hf4703r79iqnhv5y8x9kjb4nk";
    };
    installPhase = ''
      mkdir -p "$out/bin"
      tar -C $out/bin -xvf $src glow
    '';
  };


in {
  home.stateVersion = "20.03";
  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    # Standard packages from the pkgs.* namespace
    asciidoc
    cachix
    curl
    dust # Rust implementation of 'du'
    exa  # Rust implementation of 'ls'
    file
    fd   # Rust implementation of 'find'
    skim # Rust implementation of 'find'
    gcc
    go
    graphviz
    htop
    httpie
    hyperfine # Rust implementation of 'time'
    k6
    mailutils
    niv # https://github.com/nmattia/niv
    nodejs
    pandoc
    procs # Rust implementation of 'ps'
    pv
    #python3
    rlwrap
    ripgrep
    #terraform
    sqlite
    timewarrior
    tokei # Rust implementation of 'wc -l'
    traceroute
    tree
    ts
    unzip
    vault
    wiggle
    wget
    zip
    #zenith # Rust implementation of 'top'
    zsh-powerlevel10k
  ] ++ [
    # Custom packages
    #p4-metadata
    #tf-vault-provider-plugin
    #vimdiary
    ab-app-dev
    atlantis
    devqa-tools
    dhall
    dhalljson
    dhallyaml
    glow
    helpers
    p4
    p4-sandbox
    python-with-my-packages
    terraform
    vPoint
  ];

  home.activation = {
    # All these dirty things that Nix/Home Manager won't let me do
    # TODO wrap some of these steps in derivations to make things more
    # composable
    ubuntuSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
set -euxo pipefail

if [ ! -e $HOME/.akamai-apt  ] ; then
    # Install required things from apt
    $DRY_RUN_CMD sudo apt-get install -y akamai-sql akamai-nsh
    touch $HOME/.akamai-apt
fi

# Set up certs
pushd $HOME/.certs
if [ ! -e ./generate-dbattery-testnet-certificate  ] ; then
    # Get Testnet cert generator
    $DRY_RUN_CMD p4 print -o generate-dbattery-testnet-certificate //projects/syscomm/tools/generate-dbattery-testnet-certificate
fi

for U in $USER dhafeman gzaidenw ; do
    if [ ! -e ./$U-testnet.crt  ] ; then
        $DRY_RUN_CMD ./generate-dbattery-testnet-certificate --skip-validate --pem $U
        $DRY_RUN_CMD openssl pkey -in $U-testnet.pem -out $U-testnet.key
        $DRY_RUN_CMD openssl x509 -in $U-testnet.pem -out $U-testnet.crt
    fi
done

# Get Testnet Root CA
if [ ! -e $HOME/.certs/nss1-canonical_ca_roots.pem ] ; then
    $DRY_RUN_CMD p4 print -o $HOME/.certs/nss1-canonical_ca_roots.pem //projects/kmi/netconfig-ssl_ca-qa-1.10/akamai/netconfig-ssl_ca-qa/etc/ssl_ca/canonical_ca_roots.pem
fi

cat $USER.crt root_certs.pem > $USER.combined.crt
popd

# Install CBE
if [ ! -e /home/.docker ] ; then
    echo Installing CBE

    $DRY_RUN_CMD sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    $DRY_RUN_CMD sudo apt-key fingerprint 0EBFCD88
    $DRY_RUN_CMD sudo curl http://junkheap.reston.corp.akamai.com/repos/apt/gpg-key.asc | sudo apt-key add -
    $DRY_RUN_CMD sudo apt-key fingerprint 20D1FDBCD30DC9F43A89D42D30B7ADFA61BD7044

    $DRY_RUN_CMD echo "deb [arch=amd64] http://junkheap.reston.corp.akamai.com/repos/apt/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/bart_rest_api.list
    $DRY_RUN_CMD echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

    $DRY_RUN_CMD sudo apt-get update
    $DRY_RUN_CMD sudo apt-get install -y docker-ce portable-bart-rest-api

    $DRY_RUN_CMD sudo groupadd docker || true
    $DRY_RUN_CMD sudo usermod -aG docker $USER || true
    $DRY_RUN_CMD sudo systemctl enable docker

    $DRY_RUN_CMD sudo mkdir /home/.docker
    $DRY_RUN_CMD sudo chmod 750 /home/.docker
    $DRY_RUN_CMD cat << EOF | sudo tee /etc/docker/daemon.json
{ "experimental":true, "graph":"/home/.docker", "storage-driver": "overlay2" }
EOF

    $DRY_RUN_CMD sudo systemctl restart docker

    $DRY_RUN_CMD sudo setup_docker_certs --user $USER
fi

# Make my workspace
if [ ! -e ${workspace} ] ; then
    $DRY_RUN_CMD mkdir -p ${workspace}
fi

pushd ${workspace}

echo "Creating workspaces for Akamai Components: ${builtins.concatStringsSep ", " (lib.attrNames akaComps)}"
${builtins.concatStringsSep "\n" (lib.mapAttrsToList
      (name: value: "if [ ! -e ./" + name + " ] ; then $DRY_RUN_CMD workspace create " + name + " " + value + " -w " + name + "; fi")
      akaComps)};

echo "Clone git repos: ${builtins.concatStringsSep ", " (lib.attrNames gitRepos)}"
${builtins.concatStringsSep "\n" (lib.mapAttrsToList
      (name: value: "if [ ! -e ./" + name + " ] ; then $DRY_RUN_CMD git clone " + value + " " + name + "; fi")
      gitRepos)};
popd

mkdir -p $HOME/.terraform.d/plugins
if [ ! -e $HOME/.terraform.d/plugins/terraform-provider-vault ] ; then
    tar -zvf /u1/bundles/projects/shared/components/alsi9/terraform-provider-vault-2.5.0-1.0/terraform-provider-vault.tgz -C $HOME/.terraform.d/plugins/ --get ./terraform-provider-vault
fi

#if [ ! -e $HOME/workspace/metadata ] ; then
#    mkdir -p $HOME/workspace/metadata
#    cd $HOME/workspace/metadata/
#    cat <<EOF > .perforce
#P4CLIENT=ssosik_ump_metadata
#EOF
#    cat <<EOF > .envrc
#source_up
#dotenv .perforce
#export P4PORT='rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true'
#EOF
#    P4PORT="rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true" p4 client -t ssosik_ump_test_depots -o | p4 client -i
#fi

if [ ! -e $HOME/.akamai-vpoint ] ; then
    # Install VPoint
    /bin/bash <(p4 print -q //projects/platform/vtastic/vpoint/install/install_vpoint.sh)
    touch $HOME/.akamai-vpoint
fi
    '';
  };

  #nixpkgs.overlays = [ (self: super: {
  #  super.krb5.override = {
  #    enable = true;
  #  };
  #  openssh = super.openssh.override {
  #    hpnSupport = true;
  #    withKerberos = true;
  #    kerberos = self.libkrb5;
  #  };
  #  }
  #) ];

  home.file.".p10k.zsh".text = builtins.readFile "${homedir}/.config/nixpkgs/dot.p10k.zsh";
  home.file.".zshrc".text = builtins.readFile "${homedir}/.config/nixpkgs/dot.zshrc";
  home.file.".envrc".text = ''
export SSH_AUTH_SOCK=${homedir}/.ssh/ssh_auth_sock
export P4PORT="rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com"
export VAULTBIN=${homedir}/workspace/vault/vault/bin/vault
  '';
  home.file.".ssh/rc".text = ''
#!/bin/bash
if [ -S "$SSH_AUTH_SOCK" ]; then
  ln -sf $SSH_AUTH_SOCK ${homedir}/.ssh/ssh_auth_sock
fi
  '';
  home.file.".p4enviro".text = ''
P4_rsh:ssh -2 -q -a -x -l p4source p4.source.akamai.com_CHARSET=none
P4_rsh:ssh -2 -a -l p4ops -q -x p4.ops.akamai.com /bin/true_CHARSET=none
P4_rsh:ssh -q -a -x -l p4ssh p4.source.akamai.com /bin/true:1699_CHARSET=none
P4_rsh:ssh -2 -q -a -x -l p4ssh1681 perforce.akamai.com /bin/true_CHARSET=none
  '';
  #home.file.".terraform.d/plugins/terraform-provider-vault".text = builtins.readFile  "";
  home.file.".config/nix/nix.conf".text = ''
    sandbox = relaxed
    #trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM= dhall.cachix.org-1:8laGciue2JBwD49ICFtg+cIF8ddDaW7OFBjDb/dHEAo=
    #substituters = https://cache.nixos.org https://cache.dhall-lang.org https://dhall.cachix.org
  '';

  home.file.".vim/templates/skeleton.md".text = ''
---
author: {author}
date: {date}
tags:
- work
title: {title}
---
  '';

  home.file.".local/pandoc/lua/links-to-html.lua".text = ''
function Link(el)
  el.target = string.gsub(el.target, "%.md", ".html")
  return el
end
  '';

  home.sessionVariables = {
    NIX_PATH = "${homedir}/.nix-defexpr/channels";
    NIX_PROFILES = "${homedir}/.nix-profile";
    PATH = "${homedir}/.nix-profile/bin:${homedir}/bin:${homedir}/.cargo/bin:$PATH";
    SHELL = "${homedir}/.nix-profile/bin/zsh";
    LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
    POWERLEVEL9K_INSTANT_PROMPT = "quiet";
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
      enableNixDirenvIntegration = true;
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
      matchBlocks."172.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
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
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      matchBlocks."198.19.*" = {
        user = "root";
        forwardAgent = false;
        forwardX11 = false;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
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
      plugins = with pkgs.vimPlugins; [
        Jenkinsfile-vim-syntax
        ale
        ansible-vim
        calendar-vim
        dhall-vim
        direnv-vim
        emmet-vim
        fzf-vim
        goyo-vim
        jedi-vim
        jq-vim
        molokai
        nerdcommenter
        nerdtree
        nerdtree-git-plugin
        rust-vim
        tabular
        vim-airline
        vim-airline-themes
        vim-devicons
        vim-eunuch
        vim-fugitive
        vim-gitgutter
        vim-go
        vim-markdown
        vim-multiple-cursors
        vim-nix
        vim-plug
        vim-repeat
        vim-sensible
        vim-speeddating
        vim-surround
        vim-terraform
        vim-unimpaired
      ];
    };

    zsh = {
      autocd = true;
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      history = {
        extended = true;
        save = 50000;
        share = true;
        size = 50000;
      };
      oh-my-zsh = {
        enable = true;
            plugins = [ "git" "history" "taskwarrior" "virtualenv" "ripgrep" ]; # "tmuxinator" "ssh-agent"
            theme = "zsh-powerlevel10k/powerlevel10k";
            custom = "${pkgs.zsh-powerlevel10k}/share/";
      };
      shellAliases = {
        vi = "vim \$@";
        pbcopy = "tmux load-buffer -";
        pbpaste = "tmux save-buffer -";
        # Idea from https://gcollazo.com/common-nix-commands-written-in-rust/
        cat = "bat \$@";
        du="dust \$@";
        #find = "fd \$@";
        #grep="rg \$@";
        #ls = "exa \$@";
        "ls -latr" = "exa -lars modified\$@";
        #ps="procs \$@";
        #time = "hyperfine \$@";
        #"wc -l" = "dust \$@";
      };
    };

  }; # End programs

  #services = {
  #  lorri = {
  #    enable = true;
  #  };
  #};
}
