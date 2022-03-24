require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/castpoison/castpoison_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=64fd4d=0.25")
end
init = PluginLoader.add_plugin_loader("castpoison", PLUGINS_PATH, init)

function uninit()

end
