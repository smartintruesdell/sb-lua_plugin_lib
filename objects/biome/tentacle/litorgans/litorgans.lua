require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/biome/tentacle/litorgans/litorgans_plugins.config"

function init()
  object.setLightColor({0, 0, 0})
end
init = PluginLoader.add_plugin_loader("litorgans", PLUGINS_PATH, init)

function notify(notification)
  if notification.type == "lightup" then
    object.setLightColor(config.getParameter("lightColor"))
    return true
  end
end
