require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/motionattack/motionattack_plugins.config"

function init()
  animator.setParticleEmitterActive("motionattack", true)
end
init = PluginLoader.add_plugin_loader("motionattack", PLUGINS_PATH, init)

function uninit()

end
