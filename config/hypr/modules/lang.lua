-- Interface language chosen in install.sh ("en" or "es"), stored in
-- $XDG_STATE_HOME/dotfiles/language. Usage: L("English text", "Texto en español")

local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local file = io.open(state .. "/dotfiles/language", "r")
local lang = "en"
if file then
    lang = (file:read("l") or "en"):match("^%s*(.-)%s*$")
    file:close()
end

return function(en, es)
    if lang == "es" then return es end
    return en
end
