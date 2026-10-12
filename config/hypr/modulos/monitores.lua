------------------
---- MONITORES ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Para ver los nombres de tus salidas: hyprctl monitors all

local laptop  = "eDP-1"
local externo = "HDMI-A-1"

-- Pantalla de la laptop a 240 Hz
hl.monitor({ output = laptop,  mode = "1920x1080@240", position = "0x0",        scale = 1 })
-- Monitor externo a la derecha de la laptop, con su resolución preferida
hl.monitor({ output = externo, mode = "preferred",     position = "auto-right", scale = 1 })
-- Cualquier otro monitor (otra máquina, proyector, etc.)
hl.monitor({ output = "",      mode = "preferred",     position = "auto",       scale = 1 })

-- Escritorios 1-5 en la laptop y 6-10 en el monitor externo
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i),     monitor = laptop })
    hl.workspace_rule({ workspace = tostring(i + 5), monitor = externo })
end
