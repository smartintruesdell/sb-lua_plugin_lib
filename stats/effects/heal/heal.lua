require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/heal/heal_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", true)

  script.setUpdateDelta(5)

  self.healingRate = config.getParameter("healAmount", 30) / effect.duration()
end
init = PluginLoader.add_plugin_loader("heal", PLUGINS_PATH, init)

function update(dt)
  status.modifyResource("health", self.healingRate * dt)
end

function uninit()

end
