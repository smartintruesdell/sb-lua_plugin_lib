require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/protectorate/protectoratebroadsword/protectoratebroadsword_plugins.config"

function init()
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

  self.primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(self.primaryAbility)

  self.altAbility = getAltAbility()
  self.weapon:addAbility(self.altAbility)

  self.weapon:init()

  self.inactiveBaseDps = config.getParameter("inactiveBaseDps")
  self.activeBaseDps = config.getParameter("activeBaseDps")

  self.active = false
  animator.setAnimationState("sword", "inactive")
  self.primaryAbility.animKeyPrefix = "inactive"
  self.primaryAbility.baseDps = self.inactiveBaseDps
  self.primaryAbility:computeDamageAndCooldowns()
end
init = PluginLoader.add_plugin_loader("protectoratebroadsword", PLUGINS_PATH, init)

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)

  setActive(self.altAbility.active)
end

function uninit()
  self.weapon:uninit()
end

function setActive(active)
  if self.active ~= active then
    self.active = active
    if self.active then
      animator.setAnimationState("sword", "extend")
      self.primaryAbility.animKeyPrefix = "active"
      self.primaryAbility.baseDps = self.activeBaseDps
      self.primaryAbility:computeDamageAndCooldowns()
    else
      animator.setAnimationState("sword", "retract")
      self.primaryAbility.animKeyPrefix = "inactive"
      self.primaryAbility.baseDps = self.inactiveBaseDps
      self.primaryAbility:computeDamageAndCooldowns()
    end
  end
end
