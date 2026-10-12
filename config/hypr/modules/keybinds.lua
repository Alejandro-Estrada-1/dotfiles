------------------
---- KEYBINDS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- The description is what the keybind viewer shows (KB button on the bar).
-- Each one is written as L("English", "Español"); the language is chosen in install.sh.

local L = require("modules.lang")
local p = require("modules.programs")
local dsp = hl.dsp

local function bind(keys, action, description, options)
    local o = { description = description }
    for k, v in pairs(options or {}) do o[k] = v end
    hl.bind(keys, action, o)
end

local function run(cmd) return dsp.exec_cmd(cmd) end

-- Programs
bind("ALT + C",        run(p.theme_picker), L("Change theme", "Cambiar tema"))
bind("ALT + Return",   run(p.terminal),     L("Open terminal", "Abrir terminal"))
bind("SUPER + E",      run(p.file_manager), L("Open file manager", "Abrir gestor de archivos"))
bind("ALT + X",        run(p.app_menu),     L("Open application menu", "Abrir menú de aplicaciones"))
bind("ALT + Z",        run(p.power_menu),   L("Open power menu", "Abrir menú de energía"))
bind("SUPER + B",      run(p.browser),      L("Open browser", "Abrir navegador"))
bind("SUPER + N",      run(p.media_panel),  L("Media and notifications panel", "Panel de medios y notificaciones"))
bind("XF86Calculator", run(p.calculator),   L("Open calculator", "Abrir calculadora"))
bind("Print",          run(p.screenshot),   L("Take a screenshot", "Captura de pantalla"))
bind("SUPER + L",      run(p.lock),         L("Lock screen", "Bloquear pantalla"))
bind("SUPER + K",      run(p.close_bar),    L("Close the bar", "Cerrar la barra"))
bind("SUPER + J",      run(p.open_bar),     L("Open the bar", "Abrir la barra"))

-- Windows
bind("ALT + Q",   dsp.window.close(),                      L("Close active window", "Cerrar ventana activa"))
bind("SUPER + M", dsp.exit(),                              L("Exit Hyprland", "Salir de Hyprland"))
bind("SUPER + F", dsp.window.fullscreen(),                 L("Toggle fullscreen", "Pantalla completa"))
bind("ALT + F",   dsp.window.float({ action = "toggle" }), L("Toggle floating window", "Alternar ventana flotante"))
bind("ALT + S",   dsp.layout("togglesplit"),               L("Toggle split", "Alternar división"))

-- Move focus (WASD)
bind("SUPER + A", dsp.focus({ direction = "left" }),  L("Focus left", "Foco a la izquierda"))
bind("SUPER + D", dsp.focus({ direction = "right" }), L("Focus right", "Foco a la derecha"))
bind("SUPER + W", dsp.focus({ direction = "up" }),    L("Focus up", "Foco arriba"))
bind("SUPER + S", dsp.focus({ direction = "down" }),  L("Focus down", "Foco abajo"))

-- Workspaces: 1-5 on the laptop (Alt / Super), 6-10 on the external monitor (Ctrl / Ctrl+Shift)
for i = 1, 5 do
    bind("ALT + " .. i,          dsp.focus({ workspace = i }),           L("Go to workspace ", "Ir al escritorio ") .. i)
    bind("CTRL + " .. i,         dsp.focus({ workspace = i + 5 }),       L("Go to workspace ", "Ir al escritorio ") .. (i + 5))
    bind("SUPER + " .. i,        dsp.window.move({ workspace = i }),     L("Move window to workspace ", "Mover ventana al escritorio ") .. i)
    bind("CTRL + SHIFT + " .. i, dsp.window.move({ workspace = i + 5 }), L("Move window to workspace ", "Mover ventana al escritorio ") .. (i + 5))
end
bind("SUPER + mouse_down", dsp.focus({ workspace = "e+1" }), L("Next workspace", "Escritorio siguiente"))
bind("SUPER + mouse_up",   dsp.focus({ workspace = "e-1" }), L("Previous workspace", "Escritorio anterior"))

-- Monitors (the laptop is on the left and the external monitor on the right)
bind("SUPER + comma",          dsp.focus({ monitor = "left" }),        L("Focus left monitor", "Foco al monitor izquierdo"))
bind("SUPER + period",         dsp.focus({ monitor = "right" }),       L("Focus right monitor", "Foco al monitor derecho"))
bind("SUPER + SHIFT + comma",  dsp.window.move({ monitor = "left" }),  L("Move window to left monitor", "Mover ventana al monitor izquierdo"))
bind("SUPER + SHIFT + period", dsp.window.move({ monitor = "right" }), L("Move window to right monitor", "Mover ventana al monitor derecho"))

-- Mouse: move and resize windows
bind("SUPER + mouse:272", dsp.window.drag(),   L("Move window", "Mover ventana"),            { mouse = true })
bind("SUPER + mouse:273", dsp.window.resize(), L("Resize window", "Redimensionar ventana"), { mouse = true })

-- Media keys (they work on the lock screen; volume and brightness repeat when held)
local repeating = { locked = true, repeating = true }
local locked    = { locked = true }
bind("XF86AudioRaiseVolume",  run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    L("Volume up", "Subir volumen"),               repeating)
bind("XF86AudioLowerVolume",  run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    L("Volume down", "Bajar volumen"),             repeating)
bind("XF86AudioMute",         run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   L("Mute audio", "Silenciar audio"),            repeating)
bind("XF86AudioMicMute",      run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), L("Mute microphone", "Silenciar micrófono"),   repeating)
bind("XF86MonBrightnessUp",   run("brightnessctl s 2%+"),                          L("Brightness up", "Subir brillo"),            repeating)
bind("XF86MonBrightnessDown", run("brightnessctl s 2%-"),                          L("Brightness down", "Bajar brillo"),          repeating)

bind("XF86AudioNext",  run("playerctl next"),       L("Next track", "Siguiente canción"),         locked)
bind("XF86AudioPause", run("playerctl play-pause"), L("Play / pause", "Pausar / reproducir"),     locked)
bind("XF86AudioPlay",  run("playerctl play-pause"), L("Play / pause", "Pausar / reproducir"),     locked)
bind("XF86AudioPrev",  run("playerctl previous"),   L("Previous track", "Canción anterior"),      locked)
