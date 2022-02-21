require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/ranged/abilities/rocketburst/rocketburst_plugins.config"

RocketBurst = GunFire:new()

function RocketBurst:new(abilityConfig)
  local primary = config.getParameter("primaryAbility")
  return GunFire.new(self, sb.jsonMerge(primary, abilityConfig))
end
RocketBurst.new = PluginLoader.add_plugin_loader("rocketburst", PLUGINS_PATH, RocketBurst.new)

function RocketBurst:init()
  self.cooldownTimer = self.fireTime
end

function RocketBurst:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == "alt"
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

    self:setState(self.burst)
  end
end

function RocketBurst:fireProjectile(...)
  local projectileId = GunFire.fireProjectile(self, ...)
  world.callScriptedEntity(projectileId, "setApproach", self:aimVector(0))
end

function RocketBurst:muzzleFlash()
  animator.burstParticleEmitter("altMuzzleFlash", true)
  animator.playSound("altFire")
end
