require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/jumpboost/jumpboost_plugins.config"

function init()
  local bounds = mcontroller.boundBox()
  animator.setParticleEmitterOffsetRegion("jumpparticles", {bounds[1], bounds[2] + 0.2, bounds[3], bounds[2] + 0.3})
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = 0.5}
  })
end
init = PluginLoader.add_plugin_loader("jumpboost", PLUGINS_PATH, init)

function update(dt)
  animator.setParticleEmitterActive("jumpparticles", config.getParameter("particles", true) and mcontroller.jumping())
  mcontroller.controlModifiers({
      airJumpModifier = 1.5
    })
end

function uninit()

end
