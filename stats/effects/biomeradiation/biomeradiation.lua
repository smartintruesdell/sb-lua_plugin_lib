require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/biomeradiation/biomeradiation_plugins.config"

function init()
  effect.setParentDirectives(config.getParameter("directives", ""))
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeradiation", 5.0)
  self.healthPercentage = config.getParameter("healthPercentage", 0.1)
end
init = PluginLoader.add_plugin_loader("biomeradiation", PLUGINS_PATH, init)

function update(dt)
  status.setResourcePercentage("health", math.min(status.resourcePercentage("health"), self.healthPercentage))
end

function uninit()

end
