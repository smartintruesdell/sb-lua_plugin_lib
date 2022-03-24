require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/camouflage/camouflage_plugins.config"

function init()
  local alpha = math.floor(config.getParameter("alpha") * 255)
  effect.setParentDirectives(string.format("?multiply=ffffff%02x", alpha))
  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("camouflage", PLUGINS_PATH, init)
