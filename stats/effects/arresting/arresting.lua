require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/arresting/arresting_plugins.config"

function init()
  self.speedHalfLife = 6
  self.jumpHalfLife = 6
  self.totalTime = 0
end
init = PluginLoader.add_plugin_loader("arresting", PLUGINS_PATH, init)

function update(dt)
  self.totalTime = self.totalTime + dt

  local speedModifier = 1 / 2 ^ (self.totalTime / self.speedHalfLife)
  local jumpModifier = 1 / 2 ^ (self.totalTime / self.jumpHalfLife)

  mcontroller.controlModifiers({
    groundMovementModifier = speedModifier,
    speedModifier = speedModifier,
    airJumpModifier = jumpModifier
  })
end

function uninit() end
