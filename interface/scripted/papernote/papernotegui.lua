require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "interface/scripted/papernote/papernotegui_plugins.config"

function init()
  local noteText = config.getParameter("noteText", "")
  noteText = noteText:gsub("%^[#%a%x]+;", "")
  widget.setText("lblNoteText", noteText)
end
init = PluginLoader.add_plugin_loader("papernotegui", PLUGINS_PATH, init)
