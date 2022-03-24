require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/staff/boltguide/boltguide_plugins.config"

function init() end
init = PluginLoader.add_plugin_loader("boltguide", PLUGINS_PATH, init)

function update(dt)

end

function keepAlive()
  projectile.setTimeToLive(5)
end

function clearGuide()
  projectile.die()
end
