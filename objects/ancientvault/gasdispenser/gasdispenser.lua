require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/ancientvault/gasdispenser/gasdispenser_plugins.config"


function init() end
init = PluginLoader.add_plugin_loader("gasdispenser", PLUGINS_PATH,init)
