require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/poisonblock/poisonblock_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "poisonResistance", amount = 0.25}, {stat = "poisonStatusImmunity", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("poisonblock", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
