require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/killable_plugins.config"
init = PluginLoader.add_plugin_loader("killable", PLUGINS_PATH, init)

function init()
  message.setHandler("kill", projectile.die)
end
