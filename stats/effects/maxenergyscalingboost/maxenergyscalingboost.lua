require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/maxenergyscalingboost/maxenergyscalingboost_plugins.config"

function init()
  --Health Scale
  self.energyModifier = config.getParameter("energyModifier", 0)
  effect.addStatModifierGroup({{stat = "maxEnergy", effectiveMultiplier = self.energyModifier}})
end
init = PluginLoader.add_plugin_loader("maxenergyscalingboost", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
