-- Configuración de Hyprland (formato Lua, Hyprland >= 0.55)
-- Wiki: https://wiki.hypr.land/Configuring/Start/
--
-- Cada parte vive en su propio archivo dentro de modulos/.
-- Los colores, el fondo y el cursor vienen del tema activo (tema-actual.lua),
-- que genera dots-aplicar-tema. Para cambiar de tema: Alt + C.

local tema = require("modulos.tema")

require("modulos.monitores")
require("modulos.entorno")(tema)
require("modulos.autoinicio")(tema)
require("modulos.apariencia")(tema)
require("modulos.entrada")
require("modulos.atajos")
require("modulos.reglas")
