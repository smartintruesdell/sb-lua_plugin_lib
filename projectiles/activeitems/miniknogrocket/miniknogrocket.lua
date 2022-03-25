require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/activeitems/miniknogrocket/miniknogrocket_plugins.config"

function init()
  self.approach = vec2.norm(mcontroller.velocity())

  self.maxSpeed = config.getParameter("maxSpeed")
  self.controlForce = config.getParameter("controlForce")
end
init = PluginLoader.add_plugin_loader("miniknogrocket", PLUGINS_PATH, init)

function update(dt)
  mcontroller.approachVelocity(vec2.mul(self.approach, self.maxSpeed), self.controlForce)
end

function setApproach(approach)
  self.approach = approach
end
