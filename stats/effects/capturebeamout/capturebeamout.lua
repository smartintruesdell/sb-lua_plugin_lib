require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/capturebeamout/capturebeamout_plugins.config"

function init()
  animator.setAnimationState("teleport", "beamOut")
  animator.setFlipped(mcontroller.facingDirection() < 0)
  effect.setParentDirectives("?multiply=ffffff00")
  self.triggerTimer = 1.5
end
init = PluginLoader.add_plugin_loader("capturebeamout", PLUGINS_PATH, init)

function update(dt)
  self.triggerTimer = self.triggerTimer - dt
  if self.triggerTimer <= 0 then
    status.setResource("health", 0)
  end
end
