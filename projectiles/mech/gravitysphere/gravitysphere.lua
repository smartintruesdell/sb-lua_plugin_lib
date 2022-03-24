require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/mech/gravitysphere/gravitysphere_plugins.config"

function init()
  projectile.setReferenceVelocity()
  mcontroller.setVelocity({0, 0})
end
init = PluginLoader.add_plugin_loader("gravitysphere", PLUGINS_PATH, init)
