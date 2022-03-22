require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/elementalaura/elementalaura_plugins.config"

function init()
  animator.setAnimationState("aura", "windup")
end
init = PluginLoader.add_plugin_loader("elementalaura", PLUGINS_PATH, init)
