# Shared helpers for the dots-* scripts and install.sh. Source it, do not run it.
# Expects REPO to be set by the caller.

DOTS_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
DOTS_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# Interface language chosen in install.sh: "en" or "es"
DOTS_LANG="$(cat "$DOTS_STATE/language" 2>/dev/null || echo en)"

# L "English text" "Texto en español" -> prints the one for the active language
L() {
    if [[ "$DOTS_LANG" == es ]]; then printf '%s' "$2"; else printf '%s' "$1"; fi
}
