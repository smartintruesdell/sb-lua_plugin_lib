require "/scripts/util.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/ancient/monolithgate/monolithgate_plugins.config"

function init()
  self.flagAnimationStates = config.getParameter("flagAnimationStates")
  object.setInteractive(false)

  message.setHandler("isOpen", function()
    return contains(world.universeFlags(), "final_gate_key") ~= false
  end)
end
init = PluginLoader.add_plugin_loader("monolithgate", PLUGINS_PATH, init)

function update(dt)
  local currentFlags = world.universeFlags()
  for i, flag in ipairs(currentFlags) do
    if self.flagAnimationStates[flag] then
      animator.setAnimationState(self.flagAnimationStates[flag], "on")
    end
  end

  if contains(world.universeFlags(), "final_gate_key") then
    object.setInteractive(true)
  end
end
