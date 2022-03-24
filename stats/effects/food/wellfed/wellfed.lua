require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/food/wellfed/wellfed_plugins.config"

function init()
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "full")

  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterActive("healing", config.getParameter("particles", true))

  self.healingRate = 1.0 / config.getParameter("healTime", 60)

  script.setUpdateDelta(5)
end
init = PluginLoader.add_plugin_loader("wellfed", PLUGINS_PATH, init)

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
  status.setResourcePercentage("food", 1.0)
end

function uninit()

end
