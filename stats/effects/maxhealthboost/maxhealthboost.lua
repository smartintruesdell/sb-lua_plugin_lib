require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/maxhealthboost/maxhealthboost_plugins.config"

function init()
  effect.addStatModifierGroup({
    {stat = "maxHealth", amount = config.getParameter("healthAmount", 0)},
    {stat = "maxHealth", baseMultiplier = config.getParameter("healthBaseMultiplier", 1.0)},
    {stat = "maxHealth", effectiveMultiplier = config.getParameter("healthEffectiveMultiplier", 1.0)},
  })

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("maxhealthboost", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
