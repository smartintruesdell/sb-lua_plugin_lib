require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/npcreactions/particlereaction_plugins.config"

function init()
  for _,particleEmitter in ipairs(config.getParameter("particleEmitters")) do
    animator.setParticleEmitterActive(particleEmitter, true)
  end
end
init = PluginLoader.add_plugin_loader("particlereaction", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
