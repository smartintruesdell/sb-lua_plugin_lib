require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/slimeslow/slimeslow_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=347857=0.8")
end
init = PluginLoader.add_plugin_loader("slimeslow", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.5,
      speedModifier = 0.25
    })
end

function uninit()

end
