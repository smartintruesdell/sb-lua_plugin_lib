require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/guns/grenades/proximitymines/proximitymine_plugins.config"

function init()
  self.queryDelta = 10
  self.queryStep = self.queryDelta
end
init = PluginLoader.add_plugin_loader("proximitymine", PLUGINS_PATH, init)

function update(dt)
  if self.hitGround or mcontroller.onGround() then
    mcontroller.setRotation(0)
    self.hitGround = true
  else
    mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
  end

  self.queryStep = math.max(0, self.queryStep - 1)
  if self.queryStep == 0 then
    local near = world.entityQuery(mcontroller.position(), 4, { includedTypes = {"monster", "npc"} })
    for _,entityId in pairs(near) do
      if entity.isValidTarget(entityId) then
        projectile.die()
      end
    end
    self.queryStep = self.queryDelta
  end
end
