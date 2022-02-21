require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "interface/scripted/playerstationconsole/playerstationconsolegui_plugins.config"

function init()
  local hideExpansionSlots = config.getParameter("hideExpansionSlots")
  widget.setChecked("btnHideExpansionSlots", hideExpansionSlots)

  local gravity = config.getParameter("gravity")
  widget.setSliderValue("sldGravity", gravity)
end
init = PluginLoader.add_plugin_loader("playerstationconsolegui", PLUGINS_PATH, init)

function update()

end

function setHideExpansionSlots(widgetName, widgetData)
  local hidden = widget.getChecked(widgetName)
  world.sendEntityMessage(pane.sourceEntity(), "setHideExpansionSlots", hidden)
end

function setGravity(widgetName, widgetData)
  local gravity = widget.getSliderValue(widgetName)
  world.sendEntityMessage(pane.sourceEntity(), "setGravity", gravity)
end
