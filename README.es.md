# dotfiles - Hyprland

[English](README.md) | **Español**

Mi configuración de Hyprland para Arch Linux y distribuciones basadas en Arch, con 14 temas intercambiables al vuelo y una interfaz disponible en inglés o en español.

Es una reinterpretación de [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots) con cambios propios: soporte para monitor externo, fondos de pantalla nuevos, configuración de Hyprland migrada a **Lua**, interfaz bilingüe y un sistema de temas basado en paletas en lugar de copias completas de cada archivo por tema.

| Componente | Programa |
| --- | --- |
| Compositor | [Hyprland](https://hypr.land) (configuración en Lua) |
| Barra | Waybar |
| Lanzador y menús | Rofi |
| Terminal | Kitty |
| Pantalla de bloqueo | Hyprlock |
| Fondos | awww |
| Notificaciones | SwayNC |
| Información del sistema | Fastfetch |

> [!IMPORTANT]
> Esta configuración necesita **Hyprland 0.55 o superior**, porque usa `hyprland.lua` en lugar de `hyprland.conf`. El formato anterior está obsoleto desde 0.55 y se elimina en 0.57.

## Instalación

```sh
git clone https://github.com/Alejandro-Estrada-1/dotfiles.git
cd dotfiles
./install.sh
```

El repo se puede clonar en cualquier carpeta. Nada depende de un nombre de carpeta concreto (da igual si tu sistema usa `Documentos` o `Documents`): los scripts encuentran el repo a partir de su propia ubicación y todo lo demás usa `$HOME` y las variables XDG.

Lo que hace el instalador:

1. Pregunta el idioma de la interfaz (inglés o español).
2. Instala los paquetes de [`packages/pacman.txt`](packages/pacman.txt) y [`packages/aur.txt`](packages/aur.txt). Si no tienes `yay` ni `paru`, ofrece instalar `yay`.
3. Mueve lo que ya tengas en `~/.config/{hypr,waybar,rofi,...}` a `~/.config/dotfiles-backup-<fecha>/`.
4. Crea enlaces simbólicos de `~/.config/*` hacia el repo, así que **editar un archivo en `~/.config` lo edita en el repo** y git ve el cambio.
5. Enlaza los temas GTK y los cursores en `~/.local/share` (no necesita sudo).
6. Aplica el tema y revisa la configuración con `Hyprland --verify-config`.

> [!WARNING]
> El instalador reemplaza `~/.config/hypr`, `waybar`, `rofi`, `kitty`, `fastfetch`, `cava`, `swaync` y `nwg-look` por enlaces simbólicos. Tus archivos anteriores no se borran: se mueven a `~/.config/dotfiles-backup-<fecha>/`.

Opciones:

```sh
./install.sh --no-packages     # solo enlaces y tema
./install.sh --lang es         # sin preguntar: en (English) o es (Español)
./install.sh --theme anonymous # tema inicial
./install.sh --dry-run         # muestra lo que haría sin cambiar nada
```

> [!TIP]
> Ejecuta primero `./install.sh --dry-run` para ver exactamente qué archivos se moverían y enlazarían. El instalador también se puede volver a ejecutar sin problema: los enlaces que ya existen no se tocan.

> [!NOTE]
> Si ejecutas el instalador desde una sesión de Hyprland que todavía usa `hyprland.conf`, carga la configuración en Lua con `hyprctl reload full-reset`, o cierra sesión y vuelve a entrar.

## Idioma

El idioma de la interfaz abarca las descripciones de los atajos, los menús de rofi (temas, atajos, menú de energía) y los mensajes del instalador y de los scripts `dots-*`. Los archivos en sí siempre están en inglés.

Para cambiarlo después:

```sh
./install.sh --no-packages --lang en   # o --lang es
hyprctl reload                         # recarga las descripciones de los atajos
```

> [!NOTE]
> Las fechas (pantalla de bloqueo, reloj de la barra) siguen el idioma de tu sistema, no esta opción.

## Temas

`Alt + C` abre el selector: primero eliges la familia (`catppuccin` o `misc`) y luego el tema. El cambio se aplica al instante en Hyprland, Waybar, Rofi, Kitty, Hyprlock, Fastfetch, GTK, el cursor y los iconos.

Desde la terminal:

```sh
dots-apply-theme --list
dots-apply-theme red
dots-apply-theme misc/anonymous-blue
```

| catppuccin | misc |
| --- | --- |
| blue, green, lavender, mauve, peach, pink, red, sapphire, yellow | anonymous, anonymous-blue, anonymous-green, anonymous-red, black |

### Cómo funciona

Cada tema es un archivo pequeño en `themes/<familia>/<nombre>.theme` con sus colores, fondo, logo, tema GTK y cursor. Por ejemplo, [`themes/catppuccin/green.theme`](themes/catppuccin/green.theme):

```sh
ACCENT="#a6e3a1"
WALLPAPER="totoro.jpg"
LOGO="ft.png"
GTK="hypr-dots-green"
CURSOR="hypr-dots-green"
FOLDERS="cat-mocha-green"
```

`dots-apply-theme` rellena las plantillas de `themes/templates/` con esos valores y genera los archivos `current-theme.*` que lee cada programa. Los archivos generados están en `.gitignore`. La configuración de cada programa (atajos, módulos de la barra, etc.) existe **una sola vez**.

### Crear un tema

1. Pon tu fondo en `wallpapers/` y, si quieres, un logo en `config/fastfetch/logos/`.
2. Copia un tema existente, por ejemplo `themes/catppuccin/green.theme` a `themes/mios/neon.theme`.
3. Cambia los valores. Solo `ACCENT`, `WALLPAPER`, `LOGO`, `GTK` y `CURSOR` son obligatorios; el resto tiene un valor por defecto:

| Variable | Para qué sirve | Por defecto |
| --- | --- | --- |
| `TEXT` | Texto de la barra, la terminal y la pantalla de bloqueo | `ACCENT` |
| `BORDER` / `SHADOW` | Borde y sombra de la ventana activa | `ACCENT` |
| `BG` / `BG_ALT` | Fondo de los módulos de la barra y de rofi | `#1e1d2f` / `#282839` |
| `TERMINAL_BG` | Fondo de kitty | `#1e1e2e` |
| `LOCK_BG` | Interior del campo de contraseña | `#1e1e2e` |
| `LOCK_INPUT_TEXT` | Texto del campo de contraseña | `TEXT` |
| `URGENT`, `INFO` | Estados de la barra (silenciado, sin red, inhibidor de suspensión) | `#f38ba8`, `#89b4fa` |
| `URGENT_TEXT`, `INFO_TEXT` | Texto de esos estados | `URGENT`, `INFO` |
| `WAYBAR_ACCENT`, `WAYBAR_TEXT` | Un color distinto solo para la barra | `ACCENT`, `TEXT` |
| `TERMINAL_COLOR0`, `TERMINAL_BRIGHT` | Colores 0/8 y 9/10 de la terminal | `#cdd6f4`, `TEXT` |
| `FOLDERS` | Color de carpetas de Papirus (`papirus-folders -l`) | ninguno |

4. Aplícalo con `dots-apply-theme mios/neon`. También aparece en `Alt + C`.

> [!CAUTION]
> No edites a mano los archivos `current-theme.*` ni `config/hypr/hyprlock.conf`: se sobrescriben cada vez que cambias de tema. Edita las plantillas de `themes/templates/`.

## Atajos

El botón **KB** de la barra muestra la lista completa. Se lee de la configuración en vivo, así que siempre está al día.

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
| `Alt + 1...5` | Escritorios 1-5 (laptop) |
| `Ctrl + 1...5` | Escritorios 6-10 (monitor externo) |
| `Super + 1...5` | Mover ventana a 1-5 |
| `Ctrl + Shift + 1...5` | Mover ventana a 6-10 |
| `Super + ,` / `Super + .` | Foco al monitor izquierdo / derecho |
| `Super + Shift + ,` / `.` | Mover ventana al monitor izquierdo / derecho |
| `Super + E` | Gestor de archivos (Dolphin) |
| `Super + B` | Navegador (Brave) |
| `Super + L` | Bloquear pantalla |
| `Super + K` / `Super + J` | Cerrar / abrir la barra |
| `Impr Pant` | Captura de pantalla (Flameshot) |
| `Super + M` | Salir de Hyprland |

Los atajos están en [`config/hypr/modules/keybinds.lua`](config/hypr/modules/keybinds.lua) y los programas en [`config/hypr/modules/programs.lua`](config/hypr/modules/programs.lua).

## Monitores

En [`config/hypr/modules/monitors.lua`](config/hypr/modules/monitors.lua):

- `eDP-1` (laptop) a 1920x1080 @ 240 Hz, con los escritorios 1-5.
- `HDMI-A-1` (externo) a la derecha, con su resolución preferida y los escritorios 6-10.
- Cualquier otro monitor usa su resolución preferida.

Si conectas el monitor externo con la sesión ya iniciada, recibe el fondo del tema automáticamente.

> [!IMPORTANT]
> Los nombres de las salidas dependen del hardware. En otra máquina, ejecuta `hyprctl monitors all` y cambia las variables `laptop` y `external` al inicio de `monitors.lua`.

## Estructura

```
.
├── install.sh
├── packages/              pacman.txt y aur.txt
├── config/                se enlaza en ~/.config/
│   ├── hypr/
│   │   ├── hyprland.lua   punto de entrada
│   │   └── modules/       monitores, atajos, apariencia, entrada, autoinicio, reglas, idioma...
│   ├── waybar/  rofi/  kitty/  fastfetch/  cava/  swaync/  nwg-look/
├── themes/
│   ├── catppuccin/*.theme
│   ├── misc/*.theme
│   └── templates/         de aquí salen los archivos current-theme.*
├── scripts/               dots-theme, dots-apply-theme, dots-keybinds, dots-powermenu
│   └── lib/common.sh      funciones compartidas (idioma)
├── wallpapers/
└── assets/                temas GTK y cursores hypr-dots-*
```

## Sobre la migración a Lua

Desde Hyprland 0.55 el formato `hyprland.conf` (hyprlang) está obsoleto, y 0.57 lo elimina. Este repo ya usa `hyprland.lua`. En la práctica:

- `hyprctl dispatch` ahora recibe código Lua: `hyprctl dispatch 'hl.dsp.exit()'` en lugar de `hyprctl dispatch exit`.
- Hyprland elige el formato **al iniciar**. Para cambiar sin cerrar sesión: `hyprctl reload full-reset`.
- Hyprlock sigue usando su propio formato (`hyprlock.conf`).
- Para revisar la configuración sin arrancar Hyprland: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

> [!CAUTION]
> `hyprctl keyword` deja de funcionar con una configuración en Lua. Los scripts que dependan de él hay que reescribirlos.

Documentación: <https://wiki.hypr.land/Configuring/Start/>

## Desinstalar

Borra los enlaces (`~/.config/{hypr,waybar,rofi,kitty,fastfetch,cava,swaync,nwg-look}`, `~/.local/bin/dots-*`, `~/.local/share/{themes,icons}/hypr-dots-*`) y mueve de vuelta lo que quieras de `~/.config/dotfiles-backup-<fecha>/`.

## Créditos

- [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots): diseño original, temas GTK y cursores `hypr-dots-*`.
- [adi1090x/rofi](https://github.com/adi1090x/rofi): base del menú de energía.
- [Catppuccin](https://github.com/catppuccin): paleta de colores (MIT).

> [!NOTE]
> Los fondos de pantalla y los logos pertenecen a sus respectivos autores.
