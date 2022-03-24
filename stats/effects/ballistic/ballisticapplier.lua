require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/ballistic/ballisticapplier_plugins.config"

function init()
  self.angle = mcontroller.rotation()
  local vector = vec2.rotate({1, 0}, self.angle + math.pi/2)
  status.setStatusProperty("ballisticVelocity", vec2.mul(vector, 100))
end
init = PluginLoader.add_plugin_loader("ballisticapplier", PLUGINS_PATH, init)

function update()
  mcontroller.setRotation(self.angle)
end

function uninit()
  status.addEphemeralEffect("ballistic")
end
