# dotfiles · Hyprland en español

Mi configuración de Hyprland para Arch Linux (y derivadas), con 14 temas intercambiables al vuelo.

Es una reinterpretación de [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots), adaptada al español y con cambios propios: soporte para monitor externo, fondos de pantalla nuevos, configuración de Hyprland migrada a **Lua** (lista para Hyprland 0.57, donde desaparece el formato `.conf`) y un sistema de temas basado en paletas en lugar de copias completas de cada archivo.

| Componente | Programa |
| --- | --- |
| Compositor | [Hyprland](https://hypr.land) ≥ 0.55 (configuración en Lua) |
| Barra | Waybar |
| Lanzador y menús | Rofi |
| Terminal | Kitty |
| Bloqueo | Hyprlock |
| Fondos | awww |
| Notificaciones | SwayNC |
| Info del sistema | Fastfetch |

## Instalación

```sh
git clone https://github.com/<tu-usuario>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./instalar.sh
```

El instalador:

1. Instala los paquetes de [`paquetes/pacman.txt`](paquetes/pacman.txt) y [`paquetes/aur.txt`](paquetes/aur.txt). Si no tienes `yay` ni `paru`, ofrece instalar `yay`.
2. Mueve lo que ya tengas en `~/.config/{hypr,waybar,rofi,…}` a `~/.config/dotfiles-respaldo-<fecha>/`.
3. Crea enlaces simbólicos de `~/.config/*` hacia el repo, así que **lo que edites en `~/.config` se edita en el repo** y git lo ve.
4. Enlaza los temas GTK y cursores en `~/.local/share` (no necesita sudo).
5. Aplica el tema y valida la configuración con `Hyprland --verify-config`.

Opciones:

```sh
./instalar.sh --sin-paquetes     # solo enlaces y tema
./instalar.sh --tema anonymous   # tema inicial
./instalar.sh --simular          # muestra lo que haría, sin cambiar nada
```

Se puede ejecutar varias veces sin problema. Si ya estás dentro de Hyprland, después de instalar ejecuta `hyprctl reload full-reset` (o cierra sesión) para pasar del formato `.conf` a Lua.

## Temas

`Alt + C` abre el selector: primero eliges la familia (`catppuccin` o `misc`) y luego el tema. El cambio se aplica al instante en Hyprland, Waybar, Rofi, Kitty, Hyprlock, Fastfetch, GTK, cursor e iconos.

Desde la terminal:

```sh
dots-aplicar-tema --lista
dots-aplicar-tema red
dots-aplicar-tema misc/anonymous-blue
```

| catppuccin | misc |
| --- | --- |
| blue, green, lavender, mauve, peach, pink, red, sapphire, yellow | anonymous, anonymous-blue, anonymous-green, anonymous-red, black |

### Cómo funciona

Cada tema es un archivo pequeño en `temas/<familia>/<nombre>.tema` con sus colores, fondo, logo, tema GTK y cursor. Por ejemplo, [`temas/catppuccin/green.tema`](temas/catppuccin/green.tema):

```sh
ACENTO="#a6e3a1"
FONDO_PANTALLA="totoro.jpg"
LOGO="ft.png"
GTK="hypr-dots-green"
CURSOR="hypr-dots-green"
CARPETAS="cat-mocha-green"
```

`dots-aplicar-tema` rellena las plantillas de `temas/plantillas/` con esos valores y genera los archivos `tema-actual.*` que leen los programas. Esos archivos generados están en `.gitignore`. La configuración de cada programa (atajos, módulos de la barra, etc.) existe **una sola vez**.

### Crear un tema nuevo

1. Pon tu fondo en `fondos/` y, si quieres, un logo en `config/fastfetch/logos/`.
2. Copia un `.tema` existente, por ejemplo `temas/catppuccin/green.tema` → `temas/mios/neon.tema`.
3. Cambia los valores. Solo `ACENTO`, `FONDO_PANTALLA`, `LOGO`, `GTK` y `CURSOR` son obligatorios; el resto toma un valor por defecto:

| Variable | Para qué sirve | Por defecto |
| --- | --- | --- |
| `TEXTO` | Texto de barra, terminal y hyprlock | `ACENTO` |
| `BORDE` / `SOMBRA` | Borde y sombra de la ventana activa | `ACENTO` |
| `FONDO` / `FONDO_ALT` | Fondo de los módulos de la barra y de rofi | `#1e1d2f` / `#282839` |
| `FONDO_TERMINAL` | Fondo de kitty | `#1e1e2e` |
| `BLOQUEO_FONDO` | Interior del campo de contraseña | `#1e1e2e` |
| `URGENTE`, `INFO` | Estados de la barra (silenciado, sin red, inhibidor) | `#f38ba8`, `#89b4fa` |
| `WAYBAR_ACENTO`, `WAYBAR_TEXTO` | Para que la barra use otro color | `ACENTO`, `TEXTO` |
| `CARPETAS` | Color de carpetas de Papirus (`papirus-folders -l`) | — |

4. Aplica con `dots-aplicar-tema mios/neon`. Aparecerá también en `Alt + C`.

## Atajos

El botón **KB** de la barra muestra la lista completa. Sale directamente de la configuración, así que siempre está al día.

| Atajo | Acción |
| --- | --- |
| `Alt + Enter` | Terminal |
| `Alt + X` | Menú de aplicaciones |
| `Alt + Z` | Menú de energía |
| `Alt + C` | Cambiar tema |
| `Alt + Q` | Cerrar ventana |
| `Alt + F` | Ventana flotante |
| `Alt + S` | Alternar división |
| `Super + F` | Pantalla completa |
| `Super + W/A/S/D` | Mover el foco |
| `Alt + 1…5` | Escritorios 1–5 (laptop) |
| `Ctrl + 1…5` | Escritorios 6–10 (monitor externo) |
| `Super + 1…5` | Mover ventana a 1–5 |
| `Ctrl + Shift + 1…5` | Mover ventana a 6–10 |
| `Super + ,` / `Super + .` | Foco al monitor izquierdo / derecho |
| `Super + Shift + ,` / `.` | Mover ventana al monitor izquierdo / derecho |
| `Super + E` | Archivos (Dolphin) |
| `Super + B` | Navegador (Brave) |
| `Super + L` | Bloquear pantalla |
| `Super + K` / `Super + J` | Cerrar / abrir la barra |
| `Impr Pant` | Captura (Flameshot) |
| `Super + M` | Salir de Hyprland |

## Monitores

En [`config/hypr/modulos/monitores.lua`](config/hypr/modulos/monitores.lua):

- `eDP-1` (laptop) a 1920x1080 @ 240 Hz, con los escritorios 1–5.
- `HDMI-A-1` (externo) a la derecha, con su resolución preferida y los escritorios 6–10.
- Cualquier otro monitor usa su resolución preferida.

Si conectas el monitor externo con la sesión ya iniciada, recibe el fondo del tema automáticamente.

En otra máquina, cambia `laptop` y `externo` por los nombres que muestre `hyprctl monitors all`.

## Estructura

```
.
├── instalar.sh
├── paquetes/              pacman.txt y aur.txt
├── config/                se enlaza a ~/.config/
│   ├── hypr/
│   │   ├── hyprland.lua   punto de entrada
│   │   └── modulos/       monitores, atajos, apariencia, entrada, autoinicio, reglas…
│   ├── waybar/  rofi/  kitty/  fastfetch/  cava/  swaync/  nwg-look/
├── temas/
│   ├── catppuccin/*.tema
│   ├── misc/*.tema
│   └── plantillas/        de aquí salen los archivos tema-actual.*
├── scripts/               dots-tema, dots-aplicar-tema, dots-atajos (se enlazan en ~/.local/bin)
├── fondos/
└── assets/                temas GTK y cursores hypr-dots-*
```

## Sobre la migración a Lua

Desde Hyprland 0.55 el formato `hyprland.conf` (hyprlang) está obsoleto, y en 0.57 se elimina. Este repo ya usa `hyprland.lua`. Lo que cambia en la práctica:

- `hyprctl keyword` deja de funcionar.
- `hyprctl dispatch` ahora recibe código Lua. Por ejemplo, `hyprctl dispatch 'hl.dsp.exit()'` en lugar de `hyprctl dispatch exit`.
- Hyprland elige el formato **al iniciar**. Para pasar de uno a otro sin cerrar sesión: `hyprctl reload full-reset`.
- Hyprlock sigue usando su formato propio (`hyprlock.conf`).
- Para comprobar la configuración sin arrancar Hyprland: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

Documentación: <https://wiki.hypr.land/Configuring/Start/>

## Desinstalar

Borra los enlaces (`~/.config/{hypr,waybar,rofi,kitty,fastfetch,cava,swaync,nwg-look}`, `~/.local/bin/dots-*`, `~/.local/share/{themes,icons}/hypr-dots-*`) y mueve de vuelta lo que quieras de `~/.config/dotfiles-respaldo-<fecha>/`.

## Créditos

- [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots): diseño original, temas GTK y cursores `hypr-dots-*`.
- [adi1090x/rofi](https://github.com/adi1090x/rofi): base del menú de energía.
- [Catppuccin](https://github.com/catppuccin): paleta de colores (MIT).
- Los fondos de pantalla y logos pertenecen a sus respectivos autores.
