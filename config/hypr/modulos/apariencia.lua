---------------------
---- APARIENCIA ----
---------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/

return function(tema)
    local borde  = "rgba(" .. tema.borde .. "ff)"
    local sombra = "rgba(" .. tema.sombra .. "ff)"

    hl.config({
        general = {
            gaps_in     = 10,
            gaps_out    = 40,
            border_size = 3,
            col = {
                active_border   = { colors = { borde, borde }, angle = 45 },
                inactive_border = "rgba(00000000)",
            },
            resize_on_border = true,
            allow_tearing    = false,
            layout           = "dwindle",
        },

        decoration = {
            rounding         = 10,
            active_opacity   = 0.9,
            inactive_opacity = 0.3,
            shadow = {
                enabled        = true,
                range          = 25,
                render_power   = 1000,
                color          = sombra,
                color_inactive = "rgba(00000000)",
            },
            blur = {
                enabled  = true,
                size     = 1,
                passes   = 5,
                vibrancy = 0.1696,
            },
        },

        animations = {
            enabled = true,
        },

        dwindle = {
            preserve_split = true,
        },

        master = {
            new_status = "master",
        },

        misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo   = true,
        },
    })

    -- Curvas y animaciones
    -- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
    hl.curve("winIn",     { type = "bezier", points = { {0.1, 1.0},  {0.1, 1.0}   } })
    hl.curve("winOut",    { type = "bezier", points = { {0.1, 1.0},  {0.1, 1.0}   } })
    hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0},    {0.99, 0.99} } })
    hl.curve("layerOut",  { type = "bezier", points = { {0.23, 1},   {0.32, 1}    } })

    hl.animation({ leaf = "windowsIn",     enabled = true, speed = 7,  bezier = "winIn",     style = "slide" })
    hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,  bezier = "smoothOut", style = "slide" })
    hl.animation({ leaf = "windowsMove",   enabled = true, speed = 7,  bezier = "winIn",     style = "slide" })
    hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 8,  bezier = "winIn",     style = "slide" })
    hl.animation({ leaf = "workspacesOut", enabled = true, speed = 8,  bezier = "winOut",    style = "slide" })
    hl.animation({ leaf = "layersIn",      enabled = true, speed = 10, bezier = "winIn",     style = "slide" })
    hl.animation({ leaf = "layersOut",     enabled = true, speed = 3,  bezier = "layerOut",  style = "popin 50%" })
end
