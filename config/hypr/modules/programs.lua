-------------------
---- PROGRAMS ----
-------------------
-- Change the programs used by the keybinds here.

local bin = os.getenv("HOME") .. "/.local/bin"

return {
    theme_picker = bin .. "/dots-theme",
    keybinds     = bin .. "/dots-keybinds",
    power_menu   = bin .. "/dots-powermenu",
    media_panel  = "swaync-client -t -sw",
    terminal     = "kitty",
    file_manager = "thunar",
    app_menu     = "rofi -show drun",
    screenshot   = "flameshot gui -c",
    lock         = "hyprlock",
    close_bar    = "killall waybar",
    open_bar     = "waybar",
    browser      = "brave",
    calculator   = "kcalc",
}
