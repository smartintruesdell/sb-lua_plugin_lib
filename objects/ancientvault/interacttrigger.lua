require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/ancientvault/interacttrigger_plugins.config"

function init()
  self.managerUid = config.getParameter("managerUid")
  object.setInteractive(true)
end
init = PluginLoader.add_plugin_loader("interacttrigger", PLUGINS_PATH, init)

function onInteraction()
  if self.managerUid then
    world.sendEntityMessage(self.managerUid, "interact")
    animator.playSound("trigger")
  end
end
