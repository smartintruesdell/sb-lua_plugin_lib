require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/runboost/runboost_plugins.config"

function init()
  local bounds = mcontroller.boundBox()
  animator.setParticleEmitterOffsetRegion("flames", {bounds[1], bounds[2] + 0.2, bounds[3], bounds[2] + 0.3})
end
init = PluginLoader.add_plugin_loader("runboost", PLUGINS_PATH,
init)

function update(dt)
  animator.setParticleEmitterActive("flames", config.getParameter("particles", true) and mcontroller.onGround() and mcontroller.running())
  mcontroller.controlModifiers({
      speedModifier = 1.5
    })
end

function uninit()

end
