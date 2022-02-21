require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "interface/scripted/sbvn/sbvnobject_plugins.config"

function init()
  self.interactData = config.getParameter("interactData")

  message.setHandler("saveState", function(_, _, state)
      storage.gameState = state
    end)
end
init = PluginLoader.add_plugin_loader("sbvnobject", PLUGINS_PATH, init)

function onInteraction(args)
  self.interactData.gameState = storage.gameState
  return {"ScriptPane", self.interactData}
end
