require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/iceblock/iceblock_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "iceResistance", amount = 0.25}, {stat = "iceStatusImmunity", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("iceblock", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
