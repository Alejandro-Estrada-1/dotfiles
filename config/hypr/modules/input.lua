---------------
---- INPUT ----
---------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- The keyboard layout is chosen in install.sh and stored in
-- $XDG_CONFIG_HOME/dotfiles/settings.

local settings = require("modules.settings")

hl.config({
    input = {
        kb_layout  = settings.kb_layout,
        kb_variant = settings.kb_variant,
        kb_model   = "",
        kb_options = settings.kb_options,
        kb_rules   = "",

        accel_profile = "flat",
        follow_mouse  = 1,
        sensitivity   = 0.8,

        repeat_rate  = 50,
        repeat_delay = 200,

        touchpad = {
            natural_scroll = false,
        },
    },
})
