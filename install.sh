#!/usr/bin/env bash
# Installer for Arch-based distributions.
#
#   ./install.sh                 install packages, link configs and apply the theme
#   ./install.sh --no-packages   only link configs and apply the theme
#   ./install.sh --lang es       interface language: en (English) or es (Español)
#   ./install.sh --kb-layout us  keyboard layout(s), e.g. us, latam, "latam,us"
#   ./install.sh --kb-variant intl   keyboard variant ("" for none)
#   ./install.sh --kb-options grp:alt_shift_toggle   XKB options ("" for none)
#   ./install.sh --theme red     initial theme (default: the saved one, or catppuccin/green)
#   ./install.sh --dry-run       print what would be done without changing anything
#
# Anything already in ~/.config is moved to ~/.config/dotfiles-backup-<date>/
# before being replaced by a symlink to this repo.
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$REPO/scripts/lib/common.sh"

CFG="$DOTS_CONFIG"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"
BACKUP="$CFG/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

CONFIGS=(hypr waybar rofi kitty fastfetch cava swaync nwg-look)
SCRIPTS=(dots-theme dots-apply-theme dots-keybinds dots-powermenu)

PACKAGES=1
DRY_RUN=0
THEME=""
LANG_CHOICE=""
KB_LAYOUT=""
unset KB_VARIANT KB_OPTIONS   # unset = ask / use the saved value; empty = none

green=$'\e[32m'; yellow=$'\e[33m'; red=$'\e[31m'; bold=$'\e[1m'; reset=$'\e[0m'
step() { echo "${bold}${green}==>${reset}${bold} $*${reset}"; }
warn() { echo "${yellow}  $(L "warning" "aviso"): $*${reset}"; }
die()  { echo "${red}  error: $*${reset}" >&2; exit 1; }
run()  { if (( DRY_RUN )); then echo "    [dry-run] $*"; else "$@"; fi; }
short() { echo "${1/#$HOME/\~}"; }

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while (($#)); do
    case "$1" in
        --no-packages) PACKAGES=0 ;;
        --dry-run) DRY_RUN=1 ;;
        --theme) THEME="${2:?missing theme name}"; shift ;;
        --lang) LANG_CHOICE="${2:?missing language (en|es)}"; shift ;;
        --kb-layout) KB_LAYOUT="${2:?missing keyboard layout}"; shift ;;
        --kb-variant) KB_VARIANT="${2?missing keyboard variant}"; shift ;;
        --kb-options) KB_OPTIONS="${2?missing keyboard options}"; shift ;;
        -h|--help) usage ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done

[[ $EUID -eq 0 ]] && die "do not run the installer as root; it asks for sudo when needed"
command -v pacman >/dev/null || die "this installer is for Arch-based distributions (pacman not found)"

# --- 0. Preferences: interface language and keyboard layout ---
# Stored in $DOTS_SETTINGS (outside the repo). Defaults come from the saved
# settings, then from the system (LANG, localectl), then from plain English/us.
interactive=0; [[ -t 0 ]] && interactive=1

has_setting() { grep -q "^$1=" "$DOTS_SETTINGS" 2>/dev/null; }
system_x11() { localectl status 2>/dev/null | sed -n "s/^ *X11 $1: //p"; }

if has_setting language; then
    default_lang=$DOTS_LANG
elif [[ "${LANG:-}" == es* ]]; then
    default_lang=es
else
    default_lang=en
fi
if [[ -z "$LANG_CHOICE" ]]; then
    LANG_CHOICE=$default_lang
    if (( interactive )); then
        [[ $default_lang == es ]] && default_num=2 || default_num=1
        echo "${bold}Interface language / Idioma de la interfaz${reset}"
        echo "  1) English"
        echo "  2) Español"
        read -rp "Choose / Elige [$default_num]: " answer
        case "${answer:-$default_num}" in
            1|en) LANG_CHOICE=en ;;
            2|es) LANG_CHOICE=es ;;
            *) die "invalid option: $answer" ;;
        esac
    fi
fi
[[ "$LANG_CHOICE" == en || "$LANG_CHOICE" == es ]] || die "language must be 'en' or 'es'"
DOTS_LANG=$LANG_CHOICE

# Checks every comma-separated layout (and its variant) against xkeyboard-config.
# Skipped when localectl cannot list layouts (e.g. inside some containers).
valid_keyboard() { # layouts variants
    local known i
    known=$(localectl list-x11-keymap-layouts 2>/dev/null) || return 0
    [[ -z "$known" ]] && return 0
    IFS=, read -ra layouts <<<"$1"
    IFS=, read -ra variants <<<"$2"
    for i in "${!layouts[@]}"; do
        grep -qx "${layouts[i]}" <<<"$known" || { warn "$(L "unknown layout" "distribución desconocida"): ${layouts[i]}"; return 1; }
        if [[ -n "${variants[i]:-}" ]] &&
           ! localectl list-x11-keymap-variants "${layouts[i]}" 2>/dev/null | grep -qx "${variants[i]}"; then
            warn "$(L "unknown variant" "variante desconocida"): ${variants[i]} (${layouts[i]})"; return 1
        fi
    done
}

default_layout=$(dots_setting kb_layout "$(system_x11 Layout)"); default_layout=${default_layout:-us}
if has_setting kb_variant; then default_variant=$(dots_setting kb_variant ""); else default_variant=$(system_x11 Variant); fi
while :; do
    layout=${KB_LAYOUT:-$default_layout}
    # A layout given with --kb-layout does not inherit the saved variant
    if [[ -n "$KB_LAYOUT" && "$KB_LAYOUT" != "$default_layout" ]]; then
        variant=${KB_VARIANT-}
    else
        variant=${KB_VARIANT-$default_variant}
    fi
    if (( interactive )) && [[ -z "$KB_LAYOUT" ]]; then
        echo "${bold}$(L "Keyboard layout" "Distribución de teclado")${reset}"
        echo "  $(L "Examples: us, latam, es, de, fr. Several layouts: latam,us (Ctrl + Space switches)." "Ejemplos: us, latam, es, de, fr. Varias: latam,us (Ctrl + Espacio cambia entre ellas).")"
        read -rp "  $(L "Layout" "Distribución") [$default_layout]: " answer; layout=${answer:-$default_layout}
        if [[ -z "${KB_VARIANT+x}" ]]; then
            # The saved variant only makes sense for the saved layout
            [[ "$layout" == "$default_layout" ]] && suggested=$default_variant || suggested=""
            read -rp "  $(L "Variant (optional, e.g. intl, dvorak)" "Variante (opcional, ej. intl, dvorak)") [$suggested]: " answer
            variant=${answer:-$suggested}
        fi
    fi
    valid_keyboard "$layout" "$variant" && break
    (( interactive )) && [[ -z "$KB_LAYOUT" ]] || die "$(L "invalid keyboard layout" "distribución de teclado inválida"): $layout $variant"
done

# With more than one layout, add Ctrl + Space to switch between them unless
# the options already have a switching key (grp:...) or were given explicitly.
if [[ -n "${KB_OPTIONS+x}" ]]; then
    options=$KB_OPTIONS
else
    options=$(dots_setting kb_options "")
    if [[ "$layout" == *,* ]]; then
        [[ "$options" == *grp:* ]] || options="${options:+$options,}grp:ctrl_space_toggle"
    else
        # A single layout has nothing to switch to; drop grp:* so Ctrl + Space reaches the apps
        options=$(tr ',' '\n' <<<"$options" | { grep -v '^grp:' || true; } | paste -sd, -)
    fi
fi

settings_text="# Preferences for the dotfiles, written by install.sh. You can edit them by hand;
# run 'hyprctl reload' afterwards.
language=$DOTS_LANG
kb_layout=$layout
kb_variant=$variant
kb_options=$options"
run mkdir -p "$(dirname "$DOTS_SETTINGS")"
if (( DRY_RUN )); then
    echo "    [dry-run] $(L "write" "escribir") $(short "$DOTS_SETTINGS"):"; sed 's/^/      /' <<<"$settings_text"
else
    echo "$settings_text" >"$DOTS_SETTINGS"
fi
step "$(L "Language" "Idioma"): $(L "English" "Español")"
step "$(L "Keyboard" "Teclado"): $layout${variant:+ ($variant)}${options:+ [$options]}"

read_list() { grep -vE '^\s*(#|$)' "$1" | sed 's/#.*//' | awk '{print $1}'; }

# --- 1. Packages ---
if (( PACKAGES )); then
    step "$(L "Installing packages from the official repositories" "Instalando paquetes de los repositorios oficiales")"
    mapfile -t official < <(read_list "$REPO/packages/pacman.txt")
    run sudo pacman -S --needed "${official[@]}"

    step "$(L "Installing AUR packages" "Instalando paquetes del AUR")"
    mapfile -t aur < <(read_list "$REPO/packages/aur.txt")
    helper=""
    for h in paru yay; do command -v "$h" >/dev/null && { helper=$h; break; }; done
    if [[ -z "$helper" ]]; then
        read -rp "  $(L "Neither paru nor yay found. Install yay from the AUR? [Y/n] " "No hay paru ni yay. ¿Instalar yay desde el AUR? [S/n] ")" answer
        if [[ ! "$answer" =~ ^[nN] ]]; then
            run sudo pacman -S --needed base-devel git
            tmp=$(mktemp -d)
            run git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
            if (( DRY_RUN )); then echo "    [dry-run] (cd $tmp/yay-bin && makepkg -si)"; else (cd "$tmp/yay-bin" && makepkg -si); fi
            rm -rf "$tmp"
            helper=yay
        fi
    fi
    if [[ -n "$helper" ]]; then
        run "$helper" -S --needed "${aur[@]}"
    else
        warn "$(L "skipped AUR packages" "se omitieron los paquetes del AUR"): ${aur[*]}"
    fi
else
    step "$(L "Skipping package installation (--no-packages)" "Omitiendo la instalación de paquetes (--no-packages)")"
fi

# --- 2. Config symlinks ---
link() { # source destination
    local src=$1 dst=$2
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        echo "    $(L "already linked" "ya enlazado"): $(short "$dst")"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        run mkdir -p "$BACKUP"
        run mv "$dst" "$BACKUP/"
        echo "    $(L "backed up" "respaldado"): $(short "$dst") -> $(short "$BACKUP")/"
    fi
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
    echo "    $(L "linked" "enlazado"): $(short "$dst") -> $(short "$src")"
}

step "$(L "Linking configs into" "Enlazando configuraciones en") $(short "$CFG")"
for c in "${CONFIGS[@]}"; do link "$REPO/config/$c" "$CFG/$c"; done

step "$(L "Linking scripts into" "Enlazando scripts en") $(short "$BIN")"
for s in "${SCRIPTS[@]}"; do link "$REPO/scripts/$s" "$BIN/$s"; done

step "$(L "Installing GTK themes and cursors into" "Instalando temas GTK y cursores en") $(short "$DATA")"
for d in "$REPO"/assets/gtk/*/;     do link "${d%/}" "$DATA/themes/$(basename "$d")"; done
for d in "$REPO"/assets/cursors/*/; do link "${d%/}" "$DATA/icons/$(basename "$d")"; done

# --- 3. Initial theme ---
step "$(L "Applying the theme" "Aplicando el tema")"
if (( DRY_RUN )); then
    echo "    [dry-run] dots-apply-theme ${THEME:---current}"
elif [[ -n "$THEME" ]]; then
    "$REPO/scripts/dots-apply-theme" "$THEME"
else
    "$REPO/scripts/dots-apply-theme" --current
fi

# --- 4. Verify the Hyprland config ---
if command -v Hyprland >/dev/null && (( ! DRY_RUN )); then
    step "$(L "Verifying the Hyprland configuration" "Verificando la configuración de Hyprland")"
    result=$(cd /tmp && Hyprland --verify-config -c "$CFG/hypr/hyprland.lua" 2>&1 | sed -n '/parsing result/,$p' | tail -n +3)
    if [[ "$result" == "config ok" ]]; then
        echo "    config ok"
    else
        warn "$(L "Hyprland reported problems:" "Hyprland reportó problemas:")"; echo "$result" | sed 's/^/      /'
    fi
fi

echo
step "$(L "Done" "Listo")"
[[ -d "$BACKUP" ]] && echo "  $(L "Your previous files are in" "Tus archivos anteriores quedaron en") $(short "$BACKUP")"
case ":$PATH:" in
    *":$BIN:"*) ;;
    *) warn "$(short "$BIN") $(L "is not in your PATH (keybinds still work; it only matters to run the dots-* commands from a terminal)" "no está en tu PATH (los atajos funcionan igual; solo importa para usar los comandos dots-* en la terminal)")" ;;
esac
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    echo "  $(L "You are inside Hyprland. To load the Lua configuration without logging out, run:" "Estás dentro de Hyprland. Para cargar la configuración en Lua sin cerrar sesión ejecuta:")"
    echo "    hyprctl reload full-reset"
    echo "  $(L "(or log out and back in)." "(o cierra sesión y vuelve a entrar).")"
else
    echo "  $(L "Log in to Hyprland to use the configuration." "Inicia sesión en Hyprland para usar la configuración.")"
fi
