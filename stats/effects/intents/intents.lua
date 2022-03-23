require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/intents/intents_plugins.config"

function init()
   effect.setParentDirectives("multiply=00000000")

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("intents", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
