--------------------
---- AUTOINICIO ----
--------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Lo que va dentro de "hyprland.start" solo se ejecuta una vez al iniciar
-- sesión (equivale al antiguo exec-once), no en cada recarga.

-- Pone el fondo en las salidas indicadas (o en todas si no se indica ninguna)
local function poner_fondo(tema, salida)
    if tema.fondo_pantalla == "" then return end
    local destino = salida and ("-o " .. salida .. " ") or ""
    hl.exec_cmd("awww img " .. destino .. "'" .. tema.fondo_pantalla .. "'")
end

return function(tema)
    hl.on("hyprland.start", function()
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
        hl.exec_cmd("waybar")

        -- Espera a que el daemon de fondos responda antes de mandar la imagen
        local fondo = tema.fondo_pantalla ~= "" and ("awww img '" .. tema.fondo_pantalla .. "'") or "true"
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("for i in $(seq 50); do awww query >/dev/null 2>&1 && break; sleep 0.1; done; " .. fondo)

        hl.exec_cmd("hyprctl setcursor " .. tema.cursor .. " 24")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. tema.cursor .. "'")
    end)

    -- Al conectar el monitor externo después de iniciar sesión, ponerle el fondo
    hl.on("monitor.added", function(monitor)
        poner_fondo(tema, monitor.name)
    end)
end
