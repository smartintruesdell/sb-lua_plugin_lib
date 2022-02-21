require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/interface/scripted/vaultaccess/vaultaccessgui_plugins.config"

function init()
  self.closeTime = config.getParameter("closeTime")
  self.activeTime = config.getParameter("activeTime")
  self.worldId = config.getParameter("worldId")

  update()
end
init = PluginLoader.add_plugin_loader("vaultaccessgui", PLUGINS_PATH, init)

function update(dt)
  local timeRemaining = self.closeTime - world.time()
  if timeRemaining > 0 then
    timeRemaining = math.floor(timeRemaining)
    local seconds = timeRemaining % 60
    local minutes = (timeRemaining - seconds) / 60
    widget.setText("lblTime", string.format("%02d:%02d", minutes, seconds))

    widget.setProgress("prgTime", timeRemaining / self.activeTime)
  else
    pane.dismiss()
  end
end

function enterVault()
  player.warp(self.worldId, "beam")
  pane.dismiss()
end

function closeVault()
  world.sendEntityMessage(pane.sourceEntity(), "closeVault")
  pane.dismiss()
end
