require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/active/weapons/melee/energymeleeweapon_plugins.config"

function init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("energymeleeweapon")
  -- END PLUGIN LOADER --------------------------------------------------------

  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

  local primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(primaryAbility)

  local secondaryAttack = getAltAbility()
  if secondaryAttack then
    self.weapon:addAbility(secondaryAttack)
  end

  self.weapon:init()

  self.activeTime = config.getParameter("activeTime", 2.0)
  self.activeTimer = 0
  animator.setAnimationState("blade", "inactive")

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("energymeleeweapon")
  -- END PLUGIN LOADER --------------------------------------------------------
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)

  local nowActive = self.weapon.currentAbility ~= nil
  if nowActive then
    if self.activeTimer == 0 then
      animator.setAnimationState("blade", "extend")
    end
    self.activeTimer = self.activeTime
  elseif self.activeTimer > 0 then
    self.activeTimer = math.max(0, self.activeTimer - dt)
    if self.activeTimer == 0 then
      animator.setAnimationState("blade", "retract")
    end
  end
end

function uninit()
  self.weapon:uninit()
end
