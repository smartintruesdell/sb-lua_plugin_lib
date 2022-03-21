require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/castfire/castfire_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=BF3300=0.25")
end
init = PluginLoader.add_plugin_loader("castfire", PLUGINS_PATH, init)

function uninit()

end
