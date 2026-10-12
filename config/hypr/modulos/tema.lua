-- Carga el tema activo generado por dots-aplicar-tema.
-- Si todavía no existe (por ejemplo, justo después de clonar el repo),
-- usa el tema verde de Catppuccin para que Hyprland arranque igual.

local por_defecto = {
    nombre         = "catppuccin/green (por defecto)",
    borde          = "a6e3a1",
    sombra         = "a6e3a1",
    fondo_pantalla = "",
    cursor         = "hypr-dots-green",
}

local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local ok, tema = pcall(dofile, config .. "/hypr/tema-actual.lua")

if not ok or type(tema) ~= "table" then
    return por_defecto
end

for clave, valor in pairs(por_defecto) do
    if tema[clave] == nil then tema[clave] = valor end
end
return tema
