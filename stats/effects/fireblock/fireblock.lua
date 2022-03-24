require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/fireblock/fireblock_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.25}, {stat = "fireStatusImmunity", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("fireblock", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
