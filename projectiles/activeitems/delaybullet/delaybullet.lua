require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/delaybullet/delaybullet_plugins.config"

function init()
  self.delayTimer = config.getParameter("delayTime")
end
init = PluginLoader.add_plugin_loader("delaybullet", PLUGINS_PATH, init)

function update(dt)
  if self.delayTimer then
    self.delayTimer = math.max(0, self.delayTimer - dt)
    if self.delayTimer == 0 then
      self.delayTimer = nil
      trigger()
    end
  end
end

function trigger()
  mcontroller.setVelocity(vec2.mul(vec2.norm(mcontroller.velocity()), config.getParameter("triggerSpeed")))
end
