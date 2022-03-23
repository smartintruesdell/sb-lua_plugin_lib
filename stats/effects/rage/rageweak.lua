require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/rage/rageweak_plugins.config"

function init()
  --Power
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})
end
init = PluginLoader.add_plugin_loader("rageweak", PLUGINS_PATH, init)


function update(dt)

end

function uninit()

end
