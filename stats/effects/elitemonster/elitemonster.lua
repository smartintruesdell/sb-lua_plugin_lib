require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/elitemonster/elitemonster_plugins.config"

function init()
  effect.addStatModifierGroup(config.getParameter("statModifiers", {}))

  script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("elitemonster", PLUGINS_PATH, init)

function update(dt)
end

function uninit()
end
