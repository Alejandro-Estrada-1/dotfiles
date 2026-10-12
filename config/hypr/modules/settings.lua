-- User preferences chosen in install.sh, read from
-- $XDG_CONFIG_HOME/dotfiles/settings (key=value, one per line).
-- Kept outside the repo so every user has their own.

local settings = {
    language   = "en",
    kb_layout  = "us",
    kb_variant = "",
    kb_options = "",
}

local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local file = io.open(config_home .. "/dotfiles/settings", "r")
if file then
    for line in file:lines() do
        local key, value = line:match("^%s*([%w_]+)=(.-)%s*$")
        if key and settings[key] ~= nil then settings[key] = value end
    end
    file:close()
end

return settings
