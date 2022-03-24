require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/ghostlyglow/ghostlyglow_plugins.config"

function init()
  effect.setParentDirectives("fade=0000EE;0.5?border=2;BFBFFF75;00000000")
end
init = PluginLoader.add_plugin_loader("ghostlyglow", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
