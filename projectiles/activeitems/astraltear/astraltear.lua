require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/astraltear/astraltear_plugins.config"

function init()
end
init = PluginLoader.add_plugin_loader("astraltear", PLUGINS_PATH, init)

function update(dt)
end
