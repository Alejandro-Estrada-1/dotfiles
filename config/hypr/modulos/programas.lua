-----------------------
---- MIS PROGRAMAS ----
-----------------------
-- Cambia aquí los programas que usan los atajos.

local bin = os.getenv("HOME") .. "/.local/bin"

return {
    temas          = bin .. "/dots-tema",
    atajos         = bin .. "/dots-atajos",
    terminal       = "kitty",
    archivos       = "dolphin",
    menu           = "rofi -show drun",
    menu_energia   = "bash ~/.config/rofi/powermenu.sh",
    captura        = "flameshot gui -c",
    bloqueo        = "hyprlock",
    cerrar_panel   = "killall waybar",
    abrir_panel    = "waybar",
    navegador      = "brave",
    calculadora    = "kcalc",
}
