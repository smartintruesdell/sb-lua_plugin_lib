require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/wet/wet_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
end
init = PluginLoader.add_plugin_loader("wet", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
