require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/glow/glow_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("sparkles", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparkles", config.getParameter("particles", true))
  effect.setParentDirectives("fade=FFFFCC;0.03?border=2;FFFFCC20;00000000")
end
init = PluginLoader.add_plugin_loader("glow", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
