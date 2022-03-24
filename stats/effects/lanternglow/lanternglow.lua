require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/lanternglow/lanternglow_plugins.config"

function init()
  script.setUpdateDelta(3)
end
init = PluginLoader.add_plugin_loader("lanternglow", PLUGINS_PATH, init)

function update(dt)
  animator.setFlipped(mcontroller.facingDirection() == -1)
end

function uninit()

end
