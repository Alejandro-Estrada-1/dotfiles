----------------
---- ATAJOS ----
----------------
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- La descripción ("desc") es lo que muestra el visor de atajos (botón KB de la barra).

local p = require("modulos.programas")
local dsp = hl.dsp

local function atajo(teclas, accion, desc, opciones)
    local o = { description = desc }
    for k, v in pairs(opciones or {}) do o[k] = v end
    hl.bind(teclas, accion, o)
end

local function ejecutar(cmd) return dsp.exec_cmd(cmd) end

-- Programas
atajo("ALT + C",        ejecutar(p.temas),        "Cambiar tema")
atajo("ALT + Return",   ejecutar(p.terminal),     "Abrir terminal")
atajo("SUPER + E",      ejecutar(p.archivos),     "Abrir gestor de archivos")
atajo("ALT + X",        ejecutar(p.menu),         "Abrir menú de aplicaciones")
atajo("ALT + Z",        ejecutar(p.menu_energia), "Abrir menú de energía")
atajo("SUPER + B",      ejecutar(p.navegador),    "Abrir navegador")
atajo("XF86Calculator", ejecutar(p.calculadora),  "Abrir calculadora")
atajo("Print",          ejecutar(p.captura),      "Captura de pantalla")
atajo("SUPER + L",      ejecutar(p.bloqueo),      "Bloquear pantalla")
atajo("SUPER + K",      ejecutar(p.cerrar_panel), "Cerrar la barra")
atajo("SUPER + J",      ejecutar(p.abrir_panel),  "Abrir la barra")

-- Ventanas
atajo("ALT + Q",   dsp.window.close(),                     "Cerrar ventana activa")
atajo("SUPER + M", dsp.exit(),                             "Salir de Hyprland")
atajo("SUPER + F", dsp.window.fullscreen(),                "Pantalla completa")
atajo("ALT + F",   dsp.window.float({ action = "toggle" }), "Alternar ventana flotante")
atajo("ALT + S",   dsp.layout("togglesplit"),              "Alternar división")

-- Mover el foco (WASD)
atajo("SUPER + A", dsp.focus({ direction = "left" }),  "Foco a la izquierda")
atajo("SUPER + D", dsp.focus({ direction = "right" }), "Foco a la derecha")
atajo("SUPER + W", dsp.focus({ direction = "up" }),    "Foco arriba")
atajo("SUPER + S", dsp.focus({ direction = "down" }),  "Foco abajo")

-- Escritorios: 1-5 en la laptop (Alt / Super), 6-10 en el monitor externo (Ctrl / Ctrl+Shift)
for i = 1, 5 do
    atajo("ALT + " .. i,           dsp.focus({ workspace = i }),           "Ir al escritorio " .. i)
    atajo("CTRL + " .. i,          dsp.focus({ workspace = i + 5 }),       "Ir al escritorio " .. (i + 5))
    atajo("SUPER + " .. i,         dsp.window.move({ workspace = i }),     "Mover ventana al escritorio " .. i)
    atajo("CTRL + SHIFT + " .. i,  dsp.window.move({ workspace = i + 5 }), "Mover ventana al escritorio " .. (i + 5))
end
atajo("SUPER + mouse_down", dsp.focus({ workspace = "e+1" }), "Escritorio siguiente")
atajo("SUPER + mouse_up",   dsp.focus({ workspace = "e-1" }), "Escritorio anterior")

-- Monitores (la laptop está a la izquierda y el externo a la derecha)
atajo("SUPER + comma",          dsp.focus({ monitor = "left" }),        "Foco al monitor izquierdo")
atajo("SUPER + period",         dsp.focus({ monitor = "right" }),       "Foco al monitor derecho")
atajo("SUPER + SHIFT + comma",  dsp.window.move({ monitor = "left" }),  "Mover ventana al monitor izquierdo")
atajo("SUPER + SHIFT + period", dsp.window.move({ monitor = "right" }), "Mover ventana al monitor derecho")

-- Mouse: mover y redimensionar ventanas
atajo("SUPER + mouse:272", dsp.window.drag(),   "Mover ventana",       { mouse = true })
atajo("SUPER + mouse:273", dsp.window.resize(), "Redimensionar ventana", { mouse = true })

-- Teclas multimedia (funcionan con la pantalla bloqueada; volumen y brillo se repiten al mantener)
local repetible = { locked = true, repeating = true }
local bloqueado = { locked = true }
atajo("XF86AudioRaiseVolume",  ejecutar("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    "Subir volumen",       repetible)
atajo("XF86AudioLowerVolume",  ejecutar("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    "Bajar volumen",       repetible)
atajo("XF86AudioMute",         ejecutar("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   "Silenciar audio",     repetible)
atajo("XF86AudioMicMute",      ejecutar("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "Silenciar micrófono", repetible)
atajo("XF86MonBrightnessUp",   ejecutar("brightnessctl s 2%+"),                          "Subir brillo",        repetible)
atajo("XF86MonBrightnessDown", ejecutar("brightnessctl s 2%-"),                          "Bajar brillo",        repetible)

atajo("XF86AudioNext",  ejecutar("playerctl next"),       "Siguiente canción",   bloqueado)
atajo("XF86AudioPause", ejecutar("playerctl play-pause"), "Pausar / reproducir", bloqueado)
atajo("XF86AudioPlay",  ejecutar("playerctl play-pause"), "Pausar / reproducir", bloqueado)
atajo("XF86AudioPrev",  ejecutar("playerctl previous"),   "Canción anterior",    bloqueado)
