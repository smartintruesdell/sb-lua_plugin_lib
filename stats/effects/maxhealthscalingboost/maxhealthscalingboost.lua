require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/maxhealthscalingboost/maxhealthscalingboost_plugins.config"

function init()
  --Health Scale
  self.healthModifier = config.getParameter("healthModifier", 0)
  effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = self.healthModifier}})
end
init = PluginLoader.add_plugin_loader("maxhealthscalingboost", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
