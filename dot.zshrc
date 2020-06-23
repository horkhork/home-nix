# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.7.1

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias vi="vim \$@"
alias pbcopy="tmux load-buffer -"
alias pbpaste="tmux save-buffer -"

# Idea from https://gcollazo.com/common-nix-commands-written-in-rust/
alias cat="bat \$@"
alias du="dust \$@"
alias find="fd \$@"
alias grep="ripgrep \$@"
alias ls="exa \$@"
alias ps="procs \$@"
alias time="hyperfine \$@"
alias "wc -l"="dust \$@"

function pbexec {
  pbpaste
  echo "Run it? (y/n)"
  read runit
  if [[ $runit == "y" ]] || [[ $runit == "Y" ]] || [[ $runit == "yes" ]] ; then
    pbpaste | bash
  fi
}

export PATH=$HOME/.cargo/bin:$PATH
