require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/peacekeeperaugment/peacekeeperaugment_plugins.config"

function init()
  effect.addStatModifierGroup({{stat = "protection", amount = config.getParameter("protection", 0)}})
  script.setUpdateDelta(3)
end
init = PluginLoader.add_plugin_loader("peacekeeperaugment", PLUGINS_PATH, init)

function update(dt)
  animator.setFlipped(mcontroller.facingDirection() == -1)
end

function uninit()

end
