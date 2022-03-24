require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/runboost/runboost20_plugins.config"

function init()
  local bounds = mcontroller.boundBox()
end
init = PluginLoader.add_plugin_loader("runboost20", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      speedModifier = 1.20
    })
end

function uninit()

end
