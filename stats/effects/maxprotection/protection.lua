require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/maxprotection/protection_plugins.config"

function init()
  effect.addStatModifierGroup({
    {stat = "protection", amount = config.getParameter("protection", 100)},
    {stat = "grit", amount = config.getParameter("grit", 1.0)}
  })

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("protection", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
