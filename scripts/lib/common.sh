# Shared helpers for the dots-* scripts and install.sh. Source it, do not run it.
# Expects REPO to be set by the caller.

DOTS_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTS_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

# User preferences chosen in install.sh (key=value, one per line).
# Kept outside the repo so every user has their own.
DOTS_SETTINGS="$DOTS_CONFIG/dotfiles/settings"

# dots_setting <key> <default> -> prints the stored value, or the default
dots_setting() {
    local value
    value=$(sed -n "s/^$1=//p" "$DOTS_SETTINGS" 2>/dev/null | tail -n 1)
    printf '%s' "${value:-$2}"
}

# Interface language: "en" or "es"
DOTS_LANG="$(dots_setting language en)"

# L "English text" "Texto en español" -> prints the one for the active language
L() {
    if [[ "$DOTS_LANG" == es ]]; then printf '%s' "$2"; else printf '%s' "$1"; fi
}
