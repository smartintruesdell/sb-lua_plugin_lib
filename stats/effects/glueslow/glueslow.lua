require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/glueslow/glueslow_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=e6e6e6=0.4")
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.20}
  })
end
init = PluginLoader.add_plugin_loader("glueslow", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.3,
      speedModifier = 0.35,
      airJumpModifier = 0.50
    })
end

function uninit()

end
