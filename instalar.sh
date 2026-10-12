#!/usr/bin/env bash
# Instalador de los dotfiles para distribuciones basadas en Arch.
#
#   ./instalar.sh                 instala paquetes, enlaza configs y aplica el tema
#   ./instalar.sh --sin-paquetes  solo enlaza configs y aplica el tema
#   ./instalar.sh --tema red      elige el tema inicial (por defecto: el guardado o catppuccin/green)
#   ./instalar.sh --simular       muestra lo que haría sin cambiar nada
#
# Lo que ya exista en ~/.config se mueve a ~/.config/dotfiles-respaldo-<fecha>/
# antes de reemplazarlo por un enlace simbólico al repo.
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATOS="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"
RESPALDO="$CFG/dotfiles-respaldo-$(date +%Y%m%d-%H%M%S)"

CONFIGS=(hypr waybar rofi kitty fastfetch cava swaync nwg-look)
SCRIPTS=(dots-tema dots-aplicar-tema dots-atajos)

PAQUETES=1
SIMULAR=0
TEMA=""

verde=$'\e[32m'; amarillo=$'\e[33m'; rojo=$'\e[31m'; negrita=$'\e[1m'; normal=$'\e[0m'
paso()  { echo "${negrita}${verde}==>${normal}${negrita} $*${normal}"; }
aviso() { echo "${amarillo}  ! $*${normal}"; }
error() { echo "${rojo}  ✗ $*${normal}" >&2; exit 1; }
ejecutar() { if (( SIMULAR )); then echo "    [simulación] $*"; else "$@"; fi; }

uso() { sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while (($#)); do
    case "$1" in
        --sin-paquetes) PAQUETES=0 ;;
        --simular) SIMULAR=1 ;;
        --tema) TEMA="${2:?falta el nombre del tema}"; shift ;;
        -h|--ayuda|--help) uso ;;
        *) error "opción desconocida: $1 (usa --ayuda)" ;;
    esac
    shift
done

[[ $EUID -eq 0 ]] && error "no ejecutes el instalador como root; pedirá sudo cuando lo necesite"
command -v pacman >/dev/null || error "este instalador es para distribuciones basadas en Arch (no encontré pacman)"

leer_lista() { grep -vE '^\s*(#|$)' "$1" | sed 's/#.*//' | awk '{print $1}'; }

# --- 1. Paquetes ---
if (( PAQUETES )); then
    paso "Instalando paquetes de los repositorios oficiales"
    mapfile -t oficiales < <(leer_lista "$REPO/paquetes/pacman.txt")
    ejecutar sudo pacman -S --needed "${oficiales[@]}"

    paso "Instalando paquetes del AUR"
    mapfile -t aur < <(leer_lista "$REPO/paquetes/aur.txt")
    ayudante=""
    for h in paru yay; do command -v "$h" >/dev/null && { ayudante=$h; break; }; done
    if [[ -z "$ayudante" ]]; then
        read -rp "  No hay paru ni yay. ¿Instalar yay desde el AUR? [S/n] " r
        if [[ ! "$r" =~ ^[nN] ]]; then
            ejecutar sudo pacman -S --needed base-devel git
            tmp=$(mktemp -d)
            ejecutar git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
            if (( SIMULAR )); then echo "    [simulación] (cd $tmp/yay-bin && makepkg -si)"; else (cd "$tmp/yay-bin" && makepkg -si); fi
            rm -rf "$tmp"
            ayudante=yay
        fi
    fi
    if [[ -n "$ayudante" ]]; then
        ejecutar "$ayudante" -S --needed "${aur[@]}"
    else
        aviso "omitidos los paquetes del AUR: ${aur[*]}"
    fi
else
    paso "Omitiendo la instalación de paquetes (--sin-paquetes)"
fi

# --- 2. Enlaces de configuración ---
enlazar() { # origen destino
    local origen=$1 destino=$2
    if [[ -L "$destino" && "$(readlink -f "$destino")" == "$(readlink -f "$origen")" ]]; then
        echo "    ya enlazado: ${destino/#$HOME/\~}"
        return
    fi
    if [[ -e "$destino" || -L "$destino" ]]; then
        ejecutar mkdir -p "$RESPALDO"
        ejecutar mv "$destino" "$RESPALDO/"
        echo "    respaldado:  ${destino/#$HOME/\~} → ${RESPALDO/#$HOME/\~}/"
    fi
    ejecutar mkdir -p "$(dirname "$destino")"
    ejecutar ln -s "$origen" "$destino"
    echo "    enlazado:    ${destino/#$HOME/\~} → ${origen/#$HOME/\~}"
}

paso "Enlazando configuraciones en ${CFG/#$HOME/\~}"
for c in "${CONFIGS[@]}"; do enlazar "$REPO/config/$c" "$CFG/$c"; done

paso "Enlazando scripts en ${BIN/#$HOME/\~}"
for s in "${SCRIPTS[@]}"; do enlazar "$REPO/scripts/$s" "$BIN/$s"; done

paso "Instalando temas GTK y cursores en ${DATOS/#$HOME/\~}"
for d in "$REPO"/assets/gtk/*/;      do enlazar "${d%/}" "$DATOS/themes/$(basename "$d")"; done
for d in "$REPO"/assets/cursores/*/; do enlazar "${d%/}" "$DATOS/icons/$(basename "$d")"; done

# --- 3. Tema inicial ---
paso "Aplicando el tema"
if (( SIMULAR )); then
    echo "    [simulación] dots-aplicar-tema ${TEMA:---actual}"
elif [[ -n "$TEMA" ]]; then
    "$REPO/scripts/dots-aplicar-tema" "$TEMA"
else
    "$REPO/scripts/dots-aplicar-tema" --actual
fi

# --- 4. Verificar la configuración de Hyprland ---
if command -v Hyprland >/dev/null && (( ! SIMULAR )); then
    paso "Verificando la configuración de Hyprland"
    salida=$(cd /tmp && Hyprland --verify-config -c "$CFG/hypr/hyprland.lua" 2>&1 | sed -n '/parsing result/,$p' | tail -n +3)
    if [[ "$salida" == "config ok" ]]; then
        echo "    config ok"
    else
        aviso "Hyprland reportó problemas:"; echo "$salida" | sed 's/^/      /'
    fi
fi

echo
paso "Listo"
[[ -d "$RESPALDO" ]] && echo "  Tus archivos anteriores quedaron en ${RESPALDO/#$HOME/\~}"
case ":$PATH:" in *":$BIN:"*) ;; *) aviso "${BIN/#$HOME/\~} no está en tu PATH (los atajos funcionan igual; es solo para usar los comandos dots-* en la terminal)";; esac
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    echo "  Estás dentro de Hyprland. Para cargar la configuración en Lua sin cerrar sesión ejecuta:"
    echo "    hyprctl reload full-reset"
    echo "  (o cierra sesión y vuelve a entrar)."
else
    echo "  Inicia sesión en Hyprland para usar la configuración."
fi
