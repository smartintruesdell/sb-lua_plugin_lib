require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH =
  "/items/active/weapons/melee/abilities/broadsword/bladecharge/bladecharge_plugins.config"

BladeCharge = WeaponAbility:new()

function BladeCharge:init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("bladecharge")
  -- END PLUGIN LOADER --------------------------------------------------------

  BladeCharge:reset()

  self.cooldownTimer = 0

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("bladecharge")
  -- END PLUGIN LOADER --------------------------------------------------------
end

function BladeCharge:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.cooldownTimer == 0 and not self.weapon.currentAbility and not status.resourceLocked("energy") and self.fireMode == "alt" then
    self:setState(self.windup)
  end
end

function BladeCharge:windup()
  self.weapon:setStance(self.stances.windup)

  animator.setAnimationState("bladeCharge", "charge")
  animator.setParticleEmitterActive("bladeCharge", true)

  local chargeTimer = self.chargeTime
  while self.fireMode == "alt" do
    chargeTimer = math.max(0, chargeTimer - self.dt)
    if chargeTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "border=3;"..self.chargeBorder..";00000000")
    end
    coroutine.yield()
  end

  if chargeTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.slash)
  end
end

function BladeCharge:slash()
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  animator.setAnimationState("bladeCharge", "idle")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("swoosh", "fire")
  animator.playSound("chargedSwing")

  util.wait(self.stances.slash.duration, function()
              local damageArea = partDamageArea("swoosh")
              self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime
end

function BladeCharge:reset()
  animator.setGlobalTag("bladeDirectives", "")
  animator.setParticleEmitterActive("bladeCharge", false)
  animator.setAnimationState("bladeCharge", "idle")
end

function BladeCharge:uninit()
  self:reset()
end
