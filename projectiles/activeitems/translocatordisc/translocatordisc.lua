require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/activeitems/translocatordisc/translocatordisc_plugins.config"

function init()

end
init = PluginLoader.add_plugin_loader("translocatordisc", PLUGINS_PATH, init)

function update(dt)
  if not (self.ownerId and world.entityExists(self.ownerId)) then
    projectile.die()
  end

  if self.hitGround or mcontroller.onGround() then
    mcontroller.setRotation(0)
    self.hitGround = true
  else
    mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
  end
end

function teleportPosition(collidePoly)
  local resolvedPoint = world.resolvePolyCollision(collidePoly, vec2.add(mcontroller.position(), config.getParameter("teleportOffset")), config.getParameter("teleportTolerance"))
  if resolvedPoint then
    return resolvedPoint
  else
    return false
  end
end

function setOwnerId(ownerId)
  self.ownerId = ownerId
end

function kill()
  projectile.die()
end

function isTranslocatorDisc()
  return true
end
