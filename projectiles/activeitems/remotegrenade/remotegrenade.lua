require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/activeitems/remotegrenade/remotegrenade_plugins.config"

function init() end

init = PluginLoader.add_plugin_loader("remotegrenade", PLUGINS_PATH, init)

function trigger()
  projectile.die()
end
