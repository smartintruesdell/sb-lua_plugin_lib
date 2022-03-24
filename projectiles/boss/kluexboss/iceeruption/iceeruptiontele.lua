require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/boss/kluexboss/iceeruption/iceeruptiontele_plugins.config"

function init() end
init = PluginLoader.add_plugin_loader("iceeruptiontele", PLUGINS_PATH, init)

function update()
  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function destroy()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) then
    projectile.processAction(projectile.getParameter("eruptionAction"))
  end
end
