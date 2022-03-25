require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/activeitems/staff/plasmaball/plasmaball_plugins.config"

function init()
  self.delayTimer = config.getParameter("delayTime")

  self.aimPosition = mcontroller.position()

  message.setHandler("updateProjectile", function(_, _, aimPosition)
    self.aimPosition = aimPosition
    return entity.id()
  end)

  message.setHandler("kill", function()
      projectile.die()
    end)
end
init = PluginLoader.add_plugin_loader("plasmaball", PLUGINS_PATH, init)

function update(dt)
  if self.delayTimer then
    self.delayTimer = math.max(0, self.delayTimer - dt)
    if self.delayTimer == 0 then
      self.delayTimer = nil
      trigger()
    end
  end
end

function trigger()
  mcontroller.setVelocity(vec2.mul(vec2.norm(world.distance(self.aimPosition, mcontroller.position())), config.getParameter("triggerSpeed")))
end
