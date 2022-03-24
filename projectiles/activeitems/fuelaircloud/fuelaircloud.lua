require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/fuelaircloud/fuelaircloud_plugins.config"

function init()
  self.chainProjectile = config.getParameter("chainProjectile")
  self.igniteAction = config.getParameter("igniteAction")
end
init = PluginLoader.add_plugin_loader("fuelaircloud", PLUGINS_PATH, init)

function update(dt)
  if self.chainTimer then
    self.chainTimer = math.max(0, self.chainTimer - dt)
    if self.chainTimer == 0 then
      if self.chainProjectile and world.entityExists(self.chainProjectile) then
        world.callScriptedEntity(self.chainProjectile, "ignite")
      end
      projectile.die()
    end
  end
end

function ignite()
  if projectile.timeToLive() < config.getParameter("cutoffTime") then return end

  if self.igniteAction then
    projectile.processAction(self.igniteAction)
  end
  self.chainTimer = config.getParameter("chainTime")
end
