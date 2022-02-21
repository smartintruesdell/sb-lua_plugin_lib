require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/weapons/ranged/abilities/flashlight/flashlight_plugins.config"

Flashlight = WeaponAbility:new()

function Flashlight:init()
  self:reset()
end
Flashlight.init =
  PluginLoader.add_plugin_loader("flashlight", PLUGINS_PATH, Flashlight.init)

function Flashlight:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if self.fireMode == "alt" and self.lastFireMode ~= "alt" then
    self.active = not self.active
    animator.setLightActive("flashlight", self.active)
    animator.setLightActive("flashlightSpread", self.active)
    animator.playSound("flashlight")
  end
  self.lastFireMode = fireMode
end

function Flashlight:reset()
  animator.setLightActive("flashlight", false)
  animator.setLightActive("flashlightSpread", false)
  self.active = false
end

function Flashlight:uninit()
  self:reset()
end
