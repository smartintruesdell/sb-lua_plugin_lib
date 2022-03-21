require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/ballistapusher/ballistapusher_plugins.config"

function init()
  effect.addStatModifierGroup({
    {stat = "maxHealth", amount = config.getParameter("healthAmount", 0)},
    {stat = "grit", amount = config.getParameter("gritAmount", 0)}
  })

  mcontroller.controlModifiers({
    speedModifier = config.getParameter("speedModifier")
  })

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("ballistapusher", PLUGINS_PATH, init)

function update(_dt) end

function uninit() end
