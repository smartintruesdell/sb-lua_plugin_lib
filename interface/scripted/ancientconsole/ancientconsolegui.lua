require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/interface/scripted/ancientconsole/ancientconsolegui_plugins.config"

function init()
  self.activateItem = config.getParameter("activateItem")
  self.required = config.getParameter("requiredCount")

  update()
end
init = PluginLoader.add_plugin_loader("ancientconsolegui", PLUGINS_PATH, init)


function update(dt)
  local current = player.hasCountOfItem(self.activateItem)
  widget.setText("costLabel", string.format("%s / %s", current, self.required))
  widget.setFontColor("costLabel", current >= self.required and {255, 255, 255} or {255, 0, 0})
  widget.setButtonEnabled("activateButton", current >= self.required)
end

function activate()
  if player.consumeItem({name = self.activateItem, count = self.required}) then
    world.sendEntityMessage(pane.sourceEntity(), "activate")
    pane.dismiss()
  end
end
