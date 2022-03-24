require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/windswept/windswept_plugins.config"

function init()
  self.movementParameters = config.getParameter("movementParameters")
end
init = PluginLoader.add_plugin_loader("windswept", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlParameters(self.movementParameters)
end

function uninit()

end
