# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.7.1

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

function pbexec {
  pbpaste
  echo "Run it? (y/n)"
  read runit
  if [[ $runit == "y" ]] || [[ $runit == "Y" ]] || [[ $runit == "yes" ]] ; then
    pbpaste | bash
  fi
}

function api-prod {
  set -x
  P=$(echo $1 | sed 's/^\/\+//')
  shift
  curl -k $@ \
    --key $HOME/.certs/$USER.key \
      --cert $HOME/.certs/$USER.crt \
        https://api-prod.dbattery.akamai.com/$P
}

function api-test {
  set -x
  P=$(echo $1 | sed 's/^\/\+//')
  shift
  curl -k $@ \
    --key $HOME/.certs/$USER-testnet.key \
      --cert $HOME/.certs/$USER-testnet.crt \
        https://api-test.dbattery.akamai.com/$P
}

function api-qa {
  set -x
  P=$(echo $1 | sed 's/^\/\+//')
  shift
  curl -k $@ \
    --key $HOME/.certs/$USER-testnet.key \
      --cert $HOME/.certs/$USER-testnet.crt \
        https://api-prod.dbattery.shared.qa.akamai.com/$P
}
