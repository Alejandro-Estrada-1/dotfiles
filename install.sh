#!/usr/bin/env bash
# Installer for Arch-based distributions.
#
#   ./install.sh                 install packages, link configs and apply the theme
#   ./install.sh --no-packages   only link configs and apply the theme
#   ./install.sh --lang es       interface language: en (English) or es (Español)
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

green=$'\e[32m'; yellow=$'\e[33m'; red=$'\e[31m'; bold=$'\e[1m'; reset=$'\e[0m'
step() { echo "${bold}${green}==>${reset}${bold} $*${reset}"; }
warn() { echo "${yellow}  $(L "warning" "aviso"): $*${reset}"; }
die()  { echo "${red}  error: $*${reset}" >&2; exit 1; }
run()  { if (( DRY_RUN )); then echo "    [dry-run] $*"; else "$@"; fi; }
short() { echo "${1/#$HOME/\~}"; }

usage() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while (($#)); do
    case "$1" in
        --no-packages) PACKAGES=0 ;;
        --dry-run) DRY_RUN=1 ;;
        --theme) THEME="${2:?missing theme name}"; shift ;;
        --lang) LANG_CHOICE="${2:?missing language (en|es)}"; shift ;;
        -h|--help) usage ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done

[[ $EUID -eq 0 ]] && die "do not run the installer as root; it asks for sudo when needed"
command -v pacman >/dev/null || die "this installer is for Arch-based distributions (pacman not found)"

# --- 0. Interface language ---
if [[ -f "$DOTS_STATE/language" ]]; then
    default_lang="$DOTS_LANG"
elif [[ "${LANG:-}" == es* ]]; then
    default_lang=es
else
    default_lang=en
fi
if [[ -z "$LANG_CHOICE" ]]; then
    LANG_CHOICE=$default_lang
    if [[ -t 0 ]]; then
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
run mkdir -p "$DOTS_STATE"
if (( DRY_RUN )); then echo "    [dry-run] echo $DOTS_LANG > $(short "$DOTS_STATE/language")"; else echo "$DOTS_LANG" >"$DOTS_STATE/language"; fi
step "$(L "Language" "Idioma"): $(L "English" "Español")"

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
