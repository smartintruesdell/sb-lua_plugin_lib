require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/regeneration/regeneration_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterActive("healing", config.getParameter("particles", true))

  script.setUpdateDelta(5)

  self.healingRate = 1.0 / config.getParameter("healTime", 60)
end
init = PluginLoader.add_plugin_loader("regeneration", PLUGINS_PATH, init)

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function uninit()

end
