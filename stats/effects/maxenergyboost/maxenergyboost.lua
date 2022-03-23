require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/maxenergyboost/maxenergyboost_plugins.config"

function init()
  effect.addStatModifierGroup({{stat = "maxEnergy", amount = config.getParameter("energyAmount", 0)}})

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("maxenergyboost", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
