# Zsh configuration (linked to ~/.zshrc by install.sh).
# Machine-specific additions go in ~/.zshrc.local, which is not part of the repo.

# System info with the active theme's logo (~/.config/fastfetch/current-logo.png).
# It runs before the Powerlevel10k instant prompt on purpose.
command -v fastfetch >/dev/null && fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh (installed by install.sh in ~/.oh-my-zsh) ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source "$ZSH/oh-my-zsh.sh"

# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Aliases ---
alias ls='ls -sal'

# --- Tools ---
# zoxide replaces cd (cd <part of a path> jumps to the most used match)
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
# atuin: shell history search (Ctrl + R)
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# --- Optional tools: only loaded when they are installed ---
[[ -d "$HOME/.spicetify" ]] && path+=("$HOME/.spicetify")

if command -v rbenv >/dev/null; then
  eval "$(rbenv init - zsh)"
fi

if [[ -x "$HOME/miniforge3/bin/conda" ]]; then
  __conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__conda_setup"
  elif [[ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]]; then
    . "$HOME/miniforge3/etc/profile.d/conda.sh"
  else
    path=("$HOME/miniforge3/bin" $path)
  fi
  unset __conda_setup
fi

if [[ -x "$HOME/miniforge3/bin/mamba" ]]; then
  export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
  export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__mamba_setup"
  else
    alias mamba="$MAMBA_EXE"
  fi
  unset __mamba_setup
fi

# --- Machine-specific settings ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
