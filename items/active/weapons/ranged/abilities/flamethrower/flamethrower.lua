require "/items/active/weapons/ranged/gunfire.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/ranged/abilities/flamethrower/flamethrower_plugins.config"

FlamethrowerAttack = GunFire:new()

function FlamethrowerAttack:init()
  GunFire.init(self)

  self.active = false
end
FlamethrowerAttack.init =
  PluginLoader.add_plugin_loader("flamethrower", PLUGINS_PATH, FlamethrowerAttack.init)

function FlamethrowerAttack:update(dt, fireMode, shiftHeld)
  GunFire.update(self, dt, fireMode, shiftHeld)

  if self.weapon.currentAbility == self then
    if not self.active then self:activate() end
  elseif self.active then
    self:deactivate()
  end
end

function FlamethrowerAttack:muzzleFlash()
  --disable normal muzzle flash
end

function FlamethrowerAttack:activate()
  self.active = true
  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)
end

function FlamethrowerAttack:deactivate()
  self.active = false
  animator.stopAllSounds("fireStart")
  animator.stopAllSounds("fireLoop")
  animator.playSound("fireEnd")
end
