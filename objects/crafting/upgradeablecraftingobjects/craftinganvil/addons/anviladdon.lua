require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/crafting/upgradeablecraftingobjects/craftinganvil/addons/anviladdon_plugins.config"

function init()
  ObjectAddons:init(config.getParameter("addonConfig", {}), updateAnimationState)
end
init = PluginLoader.add_plugin_loader("anviladdon", PLUGINS_PATH, init)

function uninit()
  ObjectAddons:uninit()
end

function updateAnimationState()
  local isConnected = ObjectAddons:isConnectedAsAny()
  if isConnected and not storage.connected then
    animator.setAnimationState("connection", "connect")
  elseif storage.connected then
    animator.setAnimationState("connection", "connected")
  else
    animator.setAnimationState("connection", "disconnected")
  end
  storage.connected = isConnected
end
