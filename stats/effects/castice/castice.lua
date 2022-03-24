require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/castice/castice_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=4dd0fd=0.25")
end
init = PluginLoader.add_plugin_loader("castice", PLUGINS_PATH, init)

function uninit()

end
