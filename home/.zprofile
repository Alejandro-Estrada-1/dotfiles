# Login shell setup (linked to ~/.zprofile by install.sh).

# User scripts, including the dots-* commands
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# pyenv, only when it is installed
if command -v pyenv >/dev/null || [[ -d "$HOME/.pyenv/bin" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init - zsh)"
fi

# Machine-specific settings
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
