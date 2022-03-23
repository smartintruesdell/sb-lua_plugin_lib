require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/largedamageboost/largedamageboostapplier_plugins.config"

function init()
  status.addEphemeralEffect("largedamageboost")
end
init = PluginLoader.add_plugin_loader("largedamageboostapplier", PLUGINS_PATH, init)
