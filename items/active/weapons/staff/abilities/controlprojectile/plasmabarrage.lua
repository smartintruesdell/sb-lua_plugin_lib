require "/items/active/weapons/staff/abilities/controlprojectile/controlprojectile.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/staff/abilities/controlprojectile/plasmabarrage_plugins.config"

ControlProjectile.init = PluginLoader.add_plugin_loader(
  "plasmabarrage",
  PLUGINS_PATH,
  ControlProjectile.init
)

function ControlProjectile:createProjectiles()
  local aimPosition = activeItem.ownerAimPosition()
  local fireDirection = world.distance(aimPosition, self:focusPosition())[1] > 0 and 1 or -1
  local pOffset = {fireDirection * (self.projectileDistance or 0), 0}
  local basePos = activeItem.ownerAimPosition()

  local pCount = self.projectileCount or 1

  local pParams = copy(self.projectileParameters)
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  for i = 1, pCount do
    pParams.delayTime = self.projectileDelayFirst + (i - 1) * self.projectileDelayEach
    pParams.periodicActions = jarray()
    table.insert(pParams.periodicActions, {
        time = pParams.delayTime,
        ["repeat"] = false,
        action = "sound",
        options = self.triggerSound
      })

    local projectileId = world.spawnProjectile(
        self.projectileType,
        vec2.add(basePos, pOffset),
        activeItem.ownerEntityId(),
        pOffset,
        false,
        pParams
      )

    if projectileId then
      table.insert(storage.projectiles, projectileId)
      world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
    end

    pOffset = vec2.rotate(pOffset, (2 * math.pi) / pCount)
  end
end
