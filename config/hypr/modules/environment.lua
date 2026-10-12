-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

return function(theme)
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("XCURSOR_THEME", theme.cursor)
end
