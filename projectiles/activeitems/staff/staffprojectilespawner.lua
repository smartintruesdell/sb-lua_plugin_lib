require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/staff/staffprojectilespawner_plugins.config"

function init()
  self.spawnTimer = config.getParameter("spawnDelay")

  message.setHandler("updateProjectile", function(_, _, aimPosition)
      self.aimPosition = aimPosition
      if self.secondaryProjectile then
        local res = {entity.id(), self.secondaryProjectile}
        self.secondaryProjectile = nil
        return res
      else
        return entity.id()
      end
    end)

  message.setHandler("kill", function()
      projectile.die()
    end)
end
init = PluginLoader.add_plugin_loader("staffprojectilespawner", PLUGINS_PATH, init)

function update(dt)
  if self.spawnTimer > 0 then
    self.spawnTimer = math.max(0, self.spawnTimer - dt)
    if self.spawnTimer == 0 then
      local params = config.getParameter("spawnParams", {})
      params.power = projectile.power()
      params.powerMultiplier = projectile.powerMultiplier()

      self.secondaryProjectile = world.spawnProjectile(
        config.getParameter("spawnProjectile"),
        mcontroller.position(),
        projectile.sourceEntity(),
        {0, 0},
        false,
        params
      )
    end
  end
end
