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
| Gestor de archivos | Thunar (también se instala Dolphin) |
| Bandeja | nm-applet (red), blueman (Bluetooth) |
| Shell | Zsh + Oh My Zsh + Powerlevel10k, zoxide, atuin |

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

1. Pregunta el idioma de la interfaz (inglés o español) y la distribución de tu teclado.
2. Instala los paquetes de [`packages/pacman.txt`](packages/pacman.txt) y [`packages/aur.txt`](packages/aur.txt). Si no tienes `yay` ni `paru`, ofrece instalar `yay`.
3. Mueve lo que ya tengas en `~/.config/{hypr,waybar,rofi,...}` a `~/.config/dotfiles-backup-<fecha>/`.
4. Crea enlaces simbólicos de `~/.config/*` hacia el repo, así que **editar un archivo en `~/.config` lo edita en el repo** y git ve el cambio.
5. Enlaza los temas GTK y los cursores en `~/.local/share` (no necesita sudo).
6. Configura zsh: enlaza `~/.zshrc`, `~/.zprofile` y `~/.p10k.zsh`, instala Oh My Zsh con Powerlevel10k y sus plugins, y ofrece usar zsh como shell por defecto.
7. Crea las carpetas de usuario estándar (Documentos, Descargas, Imágenes...), deja Thunar como gestor de archivos por defecto y activa el servicio de Bluetooth.
8. Aplica el tema y revisa la configuración con `Hyprland --verify-config`.

> [!WARNING]
> El instalador reemplaza `~/.config/hypr`, `waybar`, `rofi`, `kitty`, `fastfetch`, `cava`, `swaync`, `nwg-look` y `atuin`, además de `~/.zshrc`, `~/.zprofile` y `~/.p10k.zsh`, por enlaces simbólicos. Tus archivos anteriores no se borran: se mueven a `~/.config/dotfiles-backup-<fecha>/`.

Opciones:

```sh
./install.sh --no-packages     # solo enlaces y tema
./install.sh --lang es         # sin preguntar: en (English) o es (Español)
./install.sh --kb-layout latam # distribución de teclado; varias con comas: "latam,us"
./install.sh --kb-variant intl # variante del teclado ("" para ninguna)
./install.sh --kb-options caps:escape  # opciones de XKB ("" para ninguna)
./install.sh --theme anonymous # tema inicial
./install.sh --dry-run         # muestra lo que haría sin cambiar nada
./install.sh --yes             # sin preguntas: pacman/AUR con --noconfirm
```

> [!TIP]
> Ejecuta primero `./install.sh --dry-run` para ver exactamente qué archivos se moverían y enlazarían. El instalador también se puede volver a ejecutar sin problema: los enlaces que ya existen no se tocan.

> [!NOTE]
> Funcionan las dos sesiones de inicio: "Hyprland" y "Hyprland (uwsm-managed)". En cualquiera de ellas se ejecuta al iniciar sesión el autoinicio estándar (`/etc/xdg/autostart`), que es lo que pone los iconos de red y Bluetooth en la barra.

> [!NOTE]
> Si ejecutas el instalador desde una sesión de Hyprland que todavía usa `hyprland.conf`, carga la configuración en Lua con `hyprctl reload full-reset`, o cierra sesión y vuelve a entrar.

## Actualizar

Como `~/.config` apunta al repo, no hace falta reinstalar nada ni reiniciar:

```sh
dots-update
```

Hace `git pull` y vuelve a ejecutar el instalador con tu idioma, teclado y tema guardados. Solo instala paquetes (y pide sudo) si cambiaron las listas de paquetes, enlaza los archivos nuevos y recarga en vivo Hyprland, Waybar y Kitty. Abre una terminal nueva para cargar los cambios de zsh.

> [!NOTE]
> Solo los cambios de autoinicio (lo que se ejecuta una vez al iniciar sesión) requieren cerrar sesión y volver a entrar.

> [!TIP]
> Si editaste archivos del repo, `dots-update` se detiene en lugar de sobrescribirlos. Guárdalos primero con `git commit` o apártalos con `git stash`.

## Shell

[`home/.zshrc`](home/.zshrc) es el mismo en todas las máquinas:

- `fastfetch` se ejecuta al abrir una terminal, con el logo del tema activo.
- Oh My Zsh con Powerlevel10k (`p10k configure` para cambiar el prompt), `zsh-autosuggestions` y `zsh-syntax-highlighting`.
- `cd` se reemplaza por [zoxide](https://github.com/ajeetdsouza/zoxide): `cd proy` salta a la carpeta más usada que coincida con "proy".
- [atuin](https://github.com/atuinsh/atuin) reemplaza la búsqueda en el historial (`Ctrl + R`).
- conda/mamba (`~/miniforge3`), pyenv, rbenv y spicetify solo se cargan si están instalados.

Lo que solo tiene sentido en una máquina va en `~/.zshrc.local` o `~/.zprofile.local`, que no forman parte del repo.

> [!NOTE]
> El historial de atuin y su clave de cifrado viven en `~/.local/share/atuin` y nunca se agregan al repo. Para llevar tu historial a otra máquina usa `atuin login` y `atuin sync`.

## Idioma y teclado

El instalador guarda lo que elijas en `~/.config/dotfiles/settings`, fuera del repo, así que cada usuario conserva lo suyo:

```ini
language=es
kb_layout=latam
kb_variant=
kb_options=
```

- **Idioma de la interfaz** (`en` o `es`): descripciones de los atajos, menús de rofi (temas, atajos, menú de energía) y mensajes del instalador y de los scripts `dots-*`. Los archivos en sí siempre están en inglés.
- **Teclado**: cualquier distribución de XKB, por ejemplo `us`, `latam`, `es`, `de` o `fr`. El valor sugerido sale de tu sistema (`localectl`). Con varias distribuciones (`latam,us`), `Ctrl + Espacio` cambia entre ellas.

Para cambiarlos después, vuelve a ejecutar el instalador o edita el archivo a mano:

```sh
./install.sh --no-packages --lang en --kb-layout us
hyprctl reload
```

> [!TIP]
> Para ver las distribuciones y variantes válidas: `localectl list-x11-keymap-layouts` y `localectl list-x11-keymap-variants <distribución>`. El instalador comprueba tu elección con esas listas.

> [!NOTE]
> La región, el formato de fecha y la zona horaria no forman parte de los dotfiles: la pantalla de bloqueo y el reloj de la barra siguen la configuración de tu sistema. Se cambian con `localectl set-locale` y `timedatectl set-timezone`.

## Carpetas de usuario y gestor de archivos

El instalador ejecuta `xdg-user-dirs-update`, que crea las carpetas estándar (Escritorio, Documentos, Descargas, Música, Imágenes, Vídeos, Plantillas, Público, Proyectos) y las registra en `~/.config/user-dirs.dirs`.

> [!NOTE]
> Los nombres siguen el idioma del sistema, no el de la interfaz: con `es_MX.UTF-8` son `Documentos`, `Descargas`, `Imágenes`... y con `en_US.UTF-8`, `Documents`, `Downloads`, `Pictures`... Las carpetas que ya existen nunca se renombran. Nada en los dotfiles depende de uno u otro nombre, así que ambos funcionan.

Thunar es el gestor de archivos por defecto (`Super + E` y cualquier acción de "abrir carpeta"), con soporte para comprimir y descomprimir (`thunar-archive-plugin` + `file-roller`) y `gvfs` para la papelera, memorias USB y teléfonos. Dolphin también se instala; para usarlo en su lugar, cambia `file_manager` en [`config/hypr/modules/programs.lua`](config/hypr/modules/programs.lua) y ejecuta `xdg-mime default org.kde.dolphin.desktop inode/directory`.

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
| `Super + E` | Gestor de archivos (Thunar) |
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
├── home/                  .zshrc, .zprofile, .p10k.zsh (se enlazan en ~)
├── config/                se enlaza en ~/.config/
│   ├── hypr/
│   │   ├── hyprland.lua   punto de entrada
│   │   └── modules/       monitores, atajos, apariencia, entrada, autoinicio, reglas, preferencias, idioma...
│   ├── waybar/  rofi/  kitty/  fastfetch/  cava/  swaync/  nwg-look/  atuin/
├── themes/
│   ├── catppuccin/*.theme
│   ├── misc/*.theme
│   └── templates/         de aquí salen los archivos current-theme.*
├── scripts/               dots-theme, dots-apply-theme, dots-keybinds, dots-powermenu, dots-update
│   └── lib/common.sh      funciones compartidas (preferencias, idioma)
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

Borra los enlaces (`~/.config/{hypr,waybar,rofi,kitty,fastfetch,cava,swaync,nwg-look,atuin}`, `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh`, `~/.local/bin/dots-*`, `~/.local/share/{themes,icons}/hypr-dots-*`) y mueve de vuelta lo que quieras de `~/.config/dotfiles-backup-<fecha>/`.

## Créditos

- [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots): diseño original, temas GTK y cursores `hypr-dots-*`.
- [adi1090x/rofi](https://github.com/adi1090x/rofi): base del menú de energía.
- [Catppuccin](https://github.com/catppuccin): paleta de colores (MIT).

> [!NOTE]
> Los fondos de pantalla y los logos pertenecen a sus respectivos autores.
