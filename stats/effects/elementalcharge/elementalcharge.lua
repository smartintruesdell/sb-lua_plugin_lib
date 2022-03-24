require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/elementalcharge/elementalcharge_plugins.config"

function init()
  local bounds = mcontroller.boundBox()
  bounds[4] = 0
  animator.setParticleEmitterOffsetRegion("charge", bounds)
  animator.setParticleEmitterActive("charge", true)
end
init = PluginLoader.add_plugin_loader("elementalcharge", PLUGINS_PATH, init)
