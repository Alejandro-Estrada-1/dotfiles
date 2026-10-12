# dotfiles - Hyprland

**English** | [Español](README.es.md)

My Hyprland setup for Arch Linux and Arch-based distributions, with 14 themes you can switch on the fly and an interface available in English or Spanish.

It is a reinterpretation of [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots) with my own changes: external monitor support, new wallpapers, a Hyprland configuration migrated to **Lua**, a bilingual interface and a palette-based theme system instead of full copies of every config file per theme.

| Component | Program |
| --- | --- |
| Compositor | [Hyprland](https://hypr.land) (Lua configuration) |
| Bar | Waybar, with a cava audio visualizer |
| Launcher and menus | Rofi |
| Terminal | Kitty |
| Lock screen | Hyprlock |
| Wallpapers | awww |
| Notifications | SwayNC, also the media control center |
| System info | Fastfetch |
| File manager | Thunar (Dolphin is also installed) |
| Tray | nm-applet (network), blueman (Bluetooth) |
| Shell | Zsh + Oh My Zsh + Powerlevel10k, zoxide, atuin |

> [!IMPORTANT]
> This configuration requires **Hyprland 0.55 or newer**, because it uses `hyprland.lua` instead of `hyprland.conf`. The old format is deprecated since 0.55 and removed in 0.57.

## Installation

```sh
git clone https://github.com/Alejandro-Estrada-1/dotfiles.git
cd dotfiles
./install.sh
```

The repo can be cloned anywhere. Nothing depends on a specific folder name: the scripts find the repo from their own location, and everything else uses `$HOME` and the XDG variables.

What the installer does:

1. Asks for the interface language (English or Spanish) and your keyboard layout.
2. Installs the packages in [`packages/pacman.txt`](packages/pacman.txt) and [`packages/aur.txt`](packages/aur.txt). If neither `yay` nor `paru` is installed, it offers to install `yay`.
3. Moves anything already in `~/.config/{hypr,waybar,rofi,...}` to `~/.config/dotfiles-backup-<date>/`.
4. Creates symlinks from `~/.config/*` to the repo, so **editing a file in `~/.config` edits it in the repo** and git sees the change.
5. Links the GTK themes and cursors into `~/.local/share` (no sudo needed).
6. Sets up zsh: links `~/.zshrc`, `~/.zprofile` and `~/.p10k.zsh`, installs Oh My Zsh with Powerlevel10k and its plugins, and offers to make zsh your default shell.
7. Creates the standard user folders (Documents, Downloads, Pictures...), makes Thunar the default file manager and enables the Bluetooth service.
8. Applies the theme and checks the configuration with `Hyprland --verify-config`.

> [!WARNING]
> The installer replaces `~/.config/hypr`, `waybar`, `rofi`, `kitty`, `fastfetch`, `cava`, `swaync`, `nwg-look` and `atuin`, plus `~/.zshrc`, `~/.zprofile` and `~/.p10k.zsh`, with symlinks. Your previous files are not deleted: they are moved to `~/.config/dotfiles-backup-<date>/`.

Options:

```sh
./install.sh --no-packages     # only links and theme
./install.sh --lang es         # skip the question: en (English) or es (Español)
./install.sh --kb-layout us    # keyboard layout; several with commas: "latam,us"
./install.sh --kb-variant intl # keyboard variant ("" for none)
./install.sh --kb-options caps:escape  # XKB options ("" for none)
./install.sh --theme anonymous # initial theme
./install.sh --dry-run         # print what it would do without changing anything
./install.sh --yes             # unattended: no questions, pacman/AUR with --noconfirm
```

> [!TIP]
> Run `./install.sh --dry-run` first to see exactly which files would be moved and linked. The installer can also be run again safely; links that already exist are left alone.

> [!NOTE]
> Both login sessions work: "Hyprland" and "Hyprland (uwsm-managed)". In either one, the standard autostart entries (`/etc/xdg/autostart`) run at login, which is what puts the network and Bluetooth icons in the bar.

> [!NOTE]
> If you run the installer from inside a Hyprland session that still uses `hyprland.conf`, load the Lua configuration with `hyprctl reload full-reset`, or log out and back in.

## Updating

Because `~/.config` points to the repo, there is no need to reinstall anything or reboot:

```sh
dots-update
```

It runs `git pull` and then the installer again with your saved language, keyboard and theme. It only installs packages (and asks for sudo) when the package lists changed, links any new file, and reloads Hyprland, Waybar and Kitty live. Open a new terminal to load zsh changes.

> [!NOTE]
> Only changes to the autostart (what runs once at login) need you to log out and back in.

> [!TIP]
> If you edited files in the repo yourself, `dots-update` stops instead of overwriting them. Commit them (`git commit`) or set them aside (`git stash`) first.

## Shell

[`home/.zshrc`](home/.zshrc) is shared by every machine:

- `fastfetch` runs when a terminal opens, with the logo of the active theme.
- Oh My Zsh with Powerlevel10k (`p10k configure` to change the prompt), `zsh-autosuggestions` and `zsh-syntax-highlighting`.
- `cd` is replaced by [zoxide](https://github.com/ajeetdsouza/zoxide): `cd proj` jumps to the most used folder matching "proj".
- [atuin](https://github.com/atuinsh/atuin) replaces the history search (`Ctrl + R`).
- conda/mamba (`~/miniforge3`), pyenv, rbenv and spicetify are only loaded if they are installed.

Settings that only make sense on one machine go in `~/.zshrc.local` or `~/.zprofile.local`, which are not part of the repo.

> [!NOTE]
> The atuin history and its encryption key live in `~/.local/share/atuin` and are never added to the repo. To bring your history to another machine, use `atuin login` and `atuin sync`.

## Language and keyboard

The installer saves your choices in `~/.config/dotfiles/settings`, outside the repo, so every user keeps their own:

```ini
language=en
kb_layout=us
kb_variant=
kb_options=
```

- **Interface language** (`en` or `es`): keybind descriptions, rofi menus (themes, keybinds, power menu) and the messages of the installer and the `dots-*` scripts. The files themselves are always in English.
- **Keyboard**: any XKB layout, for example `us`, `latam`, `es`, `de` or `fr`. The suggested value comes from your system (`localectl`). With several layouts (`latam,us`), `Ctrl + Space` switches between them.

To change them later, run the installer again or edit the file by hand:

```sh
./install.sh --no-packages --lang es --kb-layout latam
hyprctl reload
```

> [!TIP]
> To list the valid layouts and variants: `localectl list-x11-keymap-layouts` and `localectl list-x11-keymap-variants <layout>`. The installer checks your choice against these lists.

> [!NOTE]
> Region, date format and time zone are not part of the dotfiles: the lock screen and the bar clock follow your system settings. Change them with `localectl set-locale` and `timedatectl set-timezone`.

## User folders and file manager

The installer runs `xdg-user-dirs-update`, which creates the standard folders (Desktop, Documents, Downloads, Music, Pictures, Videos, Templates, Public, Projects) and records them in `~/.config/user-dirs.dirs`.

> [!NOTE]
> Folder names follow the system language, not the interface language: with `es_MX.UTF-8` they are `Documentos`, `Descargas`, `Imágenes`... and with `en_US.UTF-8`, `Documents`, `Downloads`, `Pictures`... Existing folders are never renamed. Nothing in the dotfiles assumes either name, so both work.

Thunar is the default file manager (`Super + E` and every "open folder" action), with archive support (`thunar-archive-plugin` + `file-roller`) and `gvfs` for the trash, USB drives and phones. Dolphin is installed too; to use it instead, change `file_manager` in [`config/hypr/modules/programs.lua`](config/hypr/modules/programs.lua) and run `xdg-mime default org.kde.dolphin.desktop inode/directory`.

## Themes

`Alt + C` opens the picker: first the family (`catppuccin` or `misc`), then the theme. The change is applied immediately to Hyprland, Waybar, Rofi, Kitty, Hyprlock, Fastfetch, GTK, the cursor and the icons.

From a terminal:

```sh
dots-apply-theme --list
dots-apply-theme red
dots-apply-theme misc/anonymous-blue
```

| catppuccin | misc |
| --- | --- |
| blue, green, lavender, mauve, peach, pink, red, sapphire, yellow | anonymous, anonymous-blue, anonymous-green, anonymous-red, black |

### How it works

Each theme is a small file at `themes/<family>/<name>.theme` with its colors, wallpaper, logo, GTK theme and cursor. For example, [`themes/catppuccin/green.theme`](themes/catppuccin/green.theme):

```sh
ACCENT="#a6e3a1"
WALLPAPER="totoro.jpg"
LOGO="ft.png"
GTK="hypr-dots-green"
CURSOR="hypr-dots-green"
FOLDERS="cat-mocha-green"
```

`dots-apply-theme` fills the templates in `themes/templates/` with those values and writes the `current-theme.*` files that each program reads. The generated files are listed in `.gitignore`. Each program's own configuration (keybinds, bar modules, etc.) exists **only once**.

### Creating a theme

1. Put your wallpaper in `wallpapers/` and, optionally, a logo in `config/fastfetch/logos/`.
2. Copy an existing theme, for example `themes/catppuccin/green.theme` to `themes/mine/neon.theme`.
3. Edit the values. Only `ACCENT`, `WALLPAPER`, `LOGO`, `GTK` and `CURSOR` are required; everything else has a default:

| Variable | Used for | Default |
| --- | --- | --- |
| `TEXT` | Text in the bar, terminal and lock screen | `ACCENT` |
| `BORDER` / `SHADOW` | Border and shadow of the active window | `ACCENT` |
| `BG` / `BG_ALT` | Background of bar modules and rofi | `#1e1d2f` / `#282839` |
| `TERMINAL_BG` | Kitty background | `#1e1e2e` |
| `LOCK_BG` | Inside of the password field | `#1e1e2e` |
| `LOCK_INPUT_TEXT` | Password field text | `TEXT` |
| `URGENT`, `INFO` | Bar states (muted, disconnected, idle inhibitor) | `#f38ba8`, `#89b4fa` |
| `URGENT_TEXT`, `INFO_TEXT` | Text for those states | `URGENT`, `INFO` |
| `WAYBAR_ACCENT`, `WAYBAR_TEXT` | A different color just for the bar | `ACCENT`, `TEXT` |
| `TERMINAL_COLOR0`, `TERMINAL_BRIGHT` | Terminal colors 0/8 and 9/10 | `#cdd6f4`, `TEXT` |
| `FOLDERS` | Papirus folder color (`papirus-folders -l`) | none |

4. Apply it with `dots-apply-theme mine/neon`. It also shows up in `Alt + C`.

> [!CAUTION]
> Do not edit the `current-theme.*` files, `config/hypr/hyprlock.conf` or `config/swaync/config.json` directly: they are overwritten every time the theme changes. Edit the templates in `themes/templates/` instead.

## Keybinds

The **KB** button on the bar shows the full list. It is read from the live configuration, so it is always up to date.

| Keybind | Action |
| --- | --- |
| `Alt + Enter` | Terminal |
| `Alt + X` | Application menu |
| `Alt + Z` | Power menu |
| `Alt + C` | Change theme |
| `Alt + Q` | Close window |
| `Alt + F` | Toggle floating |
| `Alt + S` | Toggle split |
| `Super + F` | Fullscreen |
| `Super + W/A/S/D` | Move focus |
| `Alt + 1...5` | Workspaces 1-5 (laptop) |
| `Ctrl + 1...5` | Workspaces 6-10 (external monitor) |
| `Super + 1...5` | Move window to 1-5 |
| `Ctrl + Shift + 1...5` | Move window to 6-10 |
| `Super + ,` / `Super + .` | Focus left / right monitor |
| `Super + Shift + ,` / `.` | Move window to left / right monitor |
| `Super + E` | File manager (Thunar) |
| `Super + B` | Browser (Brave) |
| `Super + N` | Media and notifications panel |
| `Super + L` | Lock screen |
| `Super + K` / `Super + J` | Close / open the bar |
| `Print` | Screenshot (Flameshot) |
| `Super + M` | Exit Hyprland |

Keybinds live in [`config/hypr/modules/keybinds.lua`](config/hypr/modules/keybinds.lua) and programs in [`config/hypr/modules/programs.lua`](config/hypr/modules/programs.lua).

## Media control center

The 󰝚 button on the bar (or `Super + N`) opens a small panel under it with whatever is playing: album art, title, and previous / play-pause / next buttons. Every player gets its own card (Spotify, a video in the browser, ...), so you can pause one without touching the others; switch between them with the arrows, the dots or the mouse wheel. Notifications and "Do not disturb" are listed below.

The panel is the SwayNC control center ([`themes/templates/swaync-config.json`](themes/templates/swaync-config.json)). Its style builds on the one shipped with SwayNC and only swaps the colors for the active theme, so it changes along with the rest of the desktop.

> [!NOTE]
> Any app that supports MPRIS shows up: Spotify, browsers, mpv with `mpv-mpris`, and most music players. To check what the system sees, run `playerctl -l`.

## Audio visualizer

The bars next to the tray move with any sound the system plays and stay flat in silence. They come from [`scripts/dots-cava`](scripts/dots-cava), which runs `cava` and turns its output into the `▁▂▃▄▅▆▇█` characters of the `custom/cava` Waybar module.

> [!NOTE]
> Waybar's built-in `cava` module only exists in the AUR `waybar-cava` build, which conflicts with the official `waybar` package; accepting that conflict on an update removes the visualizer. This setup uses the official package plus the script, so updates cannot break it.

## Monitors

In [`config/hypr/modules/monitors.lua`](config/hypr/modules/monitors.lua):

- `eDP-1` (laptop) at the highest refresh rate its panel supports, with workspaces 1-5.
- `HDMI-A-1` (external) to the right, at its preferred resolution, with workspaces 6-10.
- Any other monitor uses its preferred resolution.

When the external monitor is plugged in after logging in, it gets the theme's wallpaper automatically.

> [!IMPORTANT]
> Output names depend on the hardware. On another machine, run `hyprctl monitors all` and change the `laptop` and `external` variables at the top of `monitors.lua`.

## Structure

```
.
├── install.sh
├── packages/              pacman.txt and aur.txt
├── home/                  .zshrc, .zprofile, .p10k.zsh (linked into ~)
├── config/                linked into ~/.config/
│   ├── hypr/
│   │   ├── hyprland.lua   entry point
│   │   └── modules/       monitors, keybinds, appearance, input, autostart, rules, settings, lang...
│   ├── waybar/  rofi/  kitty/  fastfetch/  cava/  swaync/  nwg-look/  atuin/
├── themes/
│   ├── catppuccin/*.theme
│   ├── misc/*.theme
│   └── templates/         source of the current-theme.* files
├── scripts/               dots-theme, dots-apply-theme, dots-keybinds, dots-powermenu, dots-update, dots-cava
│   └── lib/common.sh      shared helpers (settings, language)
├── wallpapers/
└── assets/                hypr-dots-* GTK themes and cursors
```

## About the Lua migration

Since Hyprland 0.55 the `hyprland.conf` format (hyprlang) is deprecated, and 0.57 removes it. This repo already uses `hyprland.lua`. In practice:

- `hyprctl dispatch` now takes Lua code: `hyprctl dispatch 'hl.dsp.exit()'` instead of `hyprctl dispatch exit`.
- Hyprland picks the format **at startup**. To switch without logging out: `hyprctl reload full-reset`.
- Hyprlock keeps its own format (`hyprlock.conf`).
- To check the configuration without starting Hyprland: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

> [!CAUTION]
> `hyprctl keyword` no longer works with a Lua configuration. Scripts that rely on it have to be rewritten.

Documentation: <https://wiki.hypr.land/Configuring/Start/>

## Uninstalling

Remove the symlinks (`~/.config/{hypr,waybar,rofi,kitty,fastfetch,cava,swaync,nwg-look,atuin}`, `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh`, `~/.local/bin/dots-*`, `~/.local/share/{themes,icons}/hypr-dots-*`) and move back whatever you want from `~/.config/dotfiles-backup-<date>/`.

## Credits

- [sansroot/hypr-dots](https://github.com/sansroot/hypr-dots): original design, `hypr-dots-*` GTK themes and cursors.
- [adi1090x/rofi](https://github.com/adi1090x/rofi): base of the power menu.
- [Catppuccin](https://github.com/catppuccin): color palette (MIT).

> [!NOTE]
> Wallpapers and logos belong to their respective authors.
