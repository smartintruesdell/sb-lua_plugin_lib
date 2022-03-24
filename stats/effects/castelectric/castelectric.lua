require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/castelectric/castelectric_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=624dfd=0.25")
end
init = PluginLoader.add_plugin_loader("castelectric", PLUGINS_PATH, init)

function uninit()

end
