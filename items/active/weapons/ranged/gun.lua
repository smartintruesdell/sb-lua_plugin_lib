require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/active/weapons/ranged/gun_plugins.config"

function init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("gun")
  -- END PLUGIN LOADER --------------------------------------------------------

  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)

  local primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(primaryAbility)

  local secondaryAbility = getAltAbility(self.weapon.elementalType)
  if secondaryAbility then
    self.weapon:addAbility(secondaryAbility)
  end

  self.weapon:init()

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("gun")
  -- END PLUGIN LOADER --------------------------------------------------------
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function uninit()
  self.weapon:uninit()
end
