require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/unsorted/filledcapturepod/filledcapturepod_plugins.config"

function init() end
init = PluginLoader.add_plugin_loader("papernote", PLUGINS_PATH, init)

function activate()
  local configData = root.assetJson("/interface/scripted/papernote/papernotegui.config")
  configData.noteText = config.getParameter("noteText", "")
  activeItem.interact("ScriptPane", configData)

  local messageType = config.getParameter("questId", "") .. ".participantEvent"
  world.sendEntityMessage(activeItem.ownerEntityId(), messageType, nil, "foundClue")
  if config.getParameter("consumeOnUse", true) then
  	item.consume(1)
  end
end
