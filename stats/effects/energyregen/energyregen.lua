require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/energyregen/energyregen_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("energy", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("energy", config.getParameter("emissionRate", 5))
  animator.setParticleEmitterActive("energy", true)

  effect.addStatModifierGroup({
      {stat = "energyRegenPercentageRate", amount = config.getParameter("regenBonusAmount", 10)},
      {stat = "energyRegenBlockTime", effectiveMultiplier = 0}
    })
end
init = PluginLoader.add_plugin_loader("energyregen", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
