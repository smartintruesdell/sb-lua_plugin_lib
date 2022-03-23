require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/rage/rage_plugins.config"

function init()
  --Power
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})

  local enableParticles = config.getParameter("particles", true)
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", enableParticles)
end
init = PluginLoader.add_plugin_loader("rage", PLUGINS_PATH, init)


function update(dt)

end

function uninit()

end
