require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/castphysical/castphysical_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=ffffff=0.25")
end
init = PluginLoader.add_plugin_loader("castphysical", PLUGINS_PATH, init)

function uninit()

end
