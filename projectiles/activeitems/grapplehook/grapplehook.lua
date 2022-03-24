require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/grapplehook/grapplehook_plugins.config"
init = PluginLoader.add_plugin_loader("grapplehook", PLUGINS_PATH, init)

function init()
  self.ownerId = projectile.sourceEntity()
  self.breakOnSlipperyCollision = config.getParameter("breakOnSlipperyCollision")
end

function update(dt)
  if self.ownerId and world.entityExists(self.ownerId) then
    if mcontroller.stickingDirection() then
      projectile.setTimeToLive(0.5)
    elseif self.breakOnSlipperyCollision and mcontroller.isColliding() then
      kill()
    end
  else
    kill()
  end
end

function anchored()
  return mcontroller.stickingDirection()
end

function kill()
  self.dead = true
end

function shouldDestroy()
  return self.dead or projectile.timeToLive() <= 0
end
