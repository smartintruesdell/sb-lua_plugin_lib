require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/electricblock/electricblock_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "electricResistance", amount = 0.25}, {stat = "electricStatusImmunity", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("electricblock", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
