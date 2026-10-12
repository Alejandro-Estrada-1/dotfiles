-------------------
---- AUTOSTART ----
-------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Everything inside "hyprland.start" runs once at login (the old exec-once),
-- not on every reload.

-- Sets the wallpaper on the given output, or on every output if none is given
local function set_wallpaper(theme, output)
    if theme.wallpaper == "" then return end
    local target = output and ("-o " .. output .. " ") or ""
    hl.exec_cmd("awww img " .. target .. "'" .. theme.wallpaper .. "'")
end

return function(theme)
    hl.on("hyprland.start", function()
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
        hl.exec_cmd("waybar")

        -- Wait until the wallpaper daemon answers before sending the image
        local wallpaper = theme.wallpaper ~= "" and ("awww img '" .. theme.wallpaper .. "'") or "true"
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("for i in $(seq 50); do awww query >/dev/null 2>&1 && break; sleep 0.1; done; " .. wallpaper)

        hl.exec_cmd("hyprctl setcursor " .. theme.cursor .. " 24")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. theme.cursor .. "'")
    end)

    -- When the external monitor is plugged in after login, give it the wallpaper
    hl.on("monitor.added", function(monitor)
        set_wallpaper(theme, monitor.name)
    end)
end
