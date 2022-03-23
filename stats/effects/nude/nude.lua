require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/nude/nude_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "nude", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("nude", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
