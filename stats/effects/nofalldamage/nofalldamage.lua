require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/nofalldamage/nofalldamage_plugins.config"

function init()
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})
  animator.setParticleEmitterOffsetRegion("feathers", mcontroller.boundBox())
  animator.setParticleEmitterActive("feathers", true)
end
init = PluginLoader.add_plugin_loader("nofalldamage", PLUGINS_PATH, init)
