require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/redflash/redflash_plugins.config"

function init()
  effect.setParentDirectives("fade=ff0000=0.85")
end
init = PluginLoader.add_plugin_loader("redflash", PLUGINS_PATH, init)
