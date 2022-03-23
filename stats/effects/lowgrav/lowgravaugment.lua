require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/lowgrav/lowgravaugment_plugins.config"

function init()
  self.gravityModifier = config.getParameter("gravityModifier")
  self.movementParams = mcontroller.baseParameters()

  setGravityMultiplier()
end
init = PluginLoader.add_plugin_loader("lowgravaugment", PLUGINS_PATH, init)

function setGravityMultiplier()
  local oldGravityMultiplier = self.movementParams.gravityMultiplier or 1

  self.newGravityMultiplier = self.gravityModifier * oldGravityMultiplier
end

function update(dt)
  mcontroller.controlParameters({
     gravityMultiplier = self.newGravityMultiplier
  })
end

function uninit()

end
