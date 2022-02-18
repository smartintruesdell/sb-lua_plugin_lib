require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/active/weapons/boomerang/boomerang_plugins.config"

-- Module initialization ------------------------------------------------------

function init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("boomerang")
  -- END PLUGIN LOADER --------------------------------------------------------

  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters")
  self.projectileParameters.power = self.projectileParameters.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  initStances()

  self.cooldownTime = config.getParameter("cooldownTime", 0)
  self.cooldownTimer = self.cooldownTime

  checkProjectiles()
  if storage.projectileIds then
    setStance("throw")
  else
    setStance("idle")
  end

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("boomerang")
  -- END PLUGIN LOADER --------------------------------------------------------
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)
  checkProjectiles()

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.stanceName == "idle" and fireMode == "primary" and self.cooldownTimer == 0 then
    self.cooldownTimer = self.cooldownTime
    setStance("windup")
  end

  if self.stanceName == "throw" then
    if not storage.projectileIds then
      setStance("catch")
    end
  end

  updateAim()
end

function uninit()

end

function fire()
  if world.lineTileCollision(mcontroller.position(), firePosition()) then
    setStance("idle")
    return
  end

  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.ownerAimPosition = activeItem.ownerAimPosition()
  if self.aimDirection < 0 then params.processing = "?flipx" end
  local projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      params
    )
  if projectileId then
    storage.projectileIds = {projectileId}
  end
  animator.playSound("throw")
end

function checkProjectiles()
  if storage.projectileIds then
    local newProjectileIds = {}
    for i, projectileId in ipairs(storage.projectileIds) do
      if world.entityExists(projectileId) then
        local updatedProjectileIds = world.callScriptedEntity(projectileId, "projectileIds")

        if updatedProjectileIds then
          for j, updatedProjectileId in ipairs(updatedProjectileIds) do
            table.insert(newProjectileIds, updatedProjectileId)
          end
        end
      end
    end
    storage.projectileIds = #newProjectileIds > 0 and newProjectileIds or nil
  end
end
