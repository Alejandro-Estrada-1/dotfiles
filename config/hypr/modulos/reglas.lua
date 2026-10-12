---------------------------------
---- REGLAS DE VENTANAS ----
---------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignorar las peticiones de maximizar de todas las aplicaciones
hl.window_rule({
    name  = "ignorar-maximizar",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Corrige problemas al arrastrar con XWayland
hl.window_rule({
    name  = "arreglo-arrastre-xwayland",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
