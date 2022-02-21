require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/melee/abilities/broadsword/risingslash/risingslash_plugins.config"

RisingSlash = WeaponAbility:new()

function RisingSlash:init()
  self:reset()

  self.cooldownTimer = self.cooldownTime
end
RisingSlash.init =
  PluginLoader.add_plugin_loader("risingslash", PLUGINS_PATH, RisingSlash.init)

function RisingSlash:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
    and self.cooldownTimer == 0
    and self.fireMode == "alt"
    and not status.statPositive("activeMovementAbilities")
    and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function RisingSlash:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  animator.setGlobalTag("directives", "?flipx")

  util.wait(self.stances.windup.duration, function()
    return status.resourceLocked("energy")
  end)

  self:setState(self.slash)
end

function RisingSlash:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("risingSwoosh", "slash")
  animator.playSound("upswing")

  util.wait(self.stances.slash.duration, function()
    if math.abs(world.gravity(mcontroller.position())) > 0 then
      mcontroller.controlApproachYVelocity(self.dashSpeed, self.dashControlForce)
    end

    local damageArea = partDamageArea("risingSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime
  self:setState(self.freeze)
end

function RisingSlash:freeze()
  self.weapon:setStance(self.stances.freeze)
  self.weapon:updateAim()

  util.wait(self.stances.freeze.duration, function()
    mcontroller.setVelocity({0,0})
  end)
end

function RisingSlash:reset()
  animator.setGlobalTag("directives", "")
  status.clearPersistentEffects("weaponMovementAbility")
end

function RisingSlash:uninit()
  self:reset()
end
