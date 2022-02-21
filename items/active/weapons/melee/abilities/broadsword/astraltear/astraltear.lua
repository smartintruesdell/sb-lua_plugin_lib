require "/items/active/weapons/melee/abilities/broadsword/travelingslash/travelingslash.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/melee/abilities/broadsword/astraltear/astraltear_plugins.config"

AstralTear = TravelingSlash:new()
AstralTear.init = PluginLoader.add_plugin_loader("astraltear", PLUGINS_PATH, AstralTear.init)

function AstralTear:slashSound()
  return "astralTear"
end
