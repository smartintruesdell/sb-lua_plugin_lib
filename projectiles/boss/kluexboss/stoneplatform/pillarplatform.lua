require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/boss/kluexboss/stoneplatform/pillarplatform_plugins.config"

function init()
  mcontroller.setRotation(0)

  self.spawn = mcontroller.position()
  self.goal = vec2.add(self.spawn, {0, 8})

  self.speed = 4

  message.setHandler("destroy", function(_, _)
    projectile.die()
  end)
end
init = PluginLoader.add_plugin_loader("pillarplatform", PLUGINS_PATH, init)

function update(dt)
  if not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end

  local toGoal = world.distance(self.goal, mcontroller.position())
  local velocity = vec2.mul(vec2.norm(toGoal), self.speed)
  if world.magnitude(toGoal) > world.magnitude(velocity) * dt then
    mcontroller.approachVelocity(velocity, 200)
  else
    mcontroller.setPosition(self.goal)
    mcontroller.setVelocity({0,0})
  end
end
