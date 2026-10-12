-------------------------------
---- VARIABLES DE ENTORNO ----
-------------------------------
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

return function(tema)
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("XCURSOR_THEME", tema.cursor)
end
