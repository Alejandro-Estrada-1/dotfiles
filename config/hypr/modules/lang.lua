-- Interface language chosen in install.sh ("en" or "es").
-- Usage: L("English text", "Texto en español")

local lang = require("modules.settings").language

return function(en, es)
    if lang == "es" then return es end
    return en
end
