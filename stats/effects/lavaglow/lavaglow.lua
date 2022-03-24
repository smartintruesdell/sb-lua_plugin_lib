require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/lavaglow/lavaglow_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=FF4400=0.2")

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("lavaglow", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
