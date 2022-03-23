require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/statusimmunity/statusimmunity_plugins.config"

function init()
   effect.addStatModifierGroup({{stat = "statusImmunity", amount = 1}})

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("statusimmunity", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
