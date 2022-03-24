require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/regeneration/regenerationaugment_plugins.config"

function init()
  script.setUpdateDelta(5)

  self.healingRate = 1.0 / config.getParameter("healTime", 60)
end
init = PluginLoader.add_plugin_loader("regenerationaugment", PLUGINS_PATH, init)

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function uninit()

end
