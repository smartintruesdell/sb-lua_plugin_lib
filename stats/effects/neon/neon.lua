require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/neon/neon_plugins.config"

function init()
  effect.setParentDirectives("fade=000000=1.0?border=2;51BD3BFF;51BD3B00")
end
init = PluginLoader.add_plugin_loader("neon", PLUGINS_PATH, init)
