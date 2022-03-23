require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/sandstorm/sandstorm_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=D1CC87=0.1")
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.25}
  })
end
init = PluginLoader.add_plugin_loader("sandstorm", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      speedModifier = 0.7,
      airJumpModifier = 0.75
    })
end

function uninit()

end
