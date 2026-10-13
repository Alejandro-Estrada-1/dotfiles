----------------------
---- WINDOW RULES ----
----------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from every application
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Blur behind the translucent media panel (scripts/dots-media). ignore_alpha
-- keeps the fully transparent area around the panel from being blurred.
hl.layer_rule({
    name  = "blur-media-panel",
    match = { namespace = "^dots-media$" },
    blur  = true,
    ignore_alpha = 0.1,
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
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
