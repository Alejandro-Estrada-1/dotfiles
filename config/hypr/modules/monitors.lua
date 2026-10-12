------------------
---- MONITORS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- To list your outputs: hyprctl monitors all

local laptop   = "eDP-1"
local external = "HDMI-A-1"

-- Laptop panel at 240 Hz
hl.monitor({ output = laptop,   mode = "1920x1080@240", position = "0x0",        scale = 1 })
-- External monitor to the right of the laptop, at its preferred resolution
hl.monitor({ output = external, mode = "preferred",     position = "auto-right", scale = 1 })
-- Any other monitor (another machine, a projector, etc.)
hl.monitor({ output = "",       mode = "preferred",     position = "auto",       scale = 1 })

-- Workspaces 1-5 on the laptop and 6-10 on the external monitor
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i),     monitor = laptop })
    hl.workspace_rule({ workspace = tostring(i + 5), monitor = external })
end
