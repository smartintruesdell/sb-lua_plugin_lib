require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/biomeairless/biomeairless_plugins.config"

function init()
  self.played = false
end

init = PluginLoader.add_plugin_loader("biomeairless", PLUGINS_PATH, init)
function update(dt)
  if not self.played and not world.breathable(entity.position()) then
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeairless", 5.0)
    self.played = true
  end
end

function uninit()
end
