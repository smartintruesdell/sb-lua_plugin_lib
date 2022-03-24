require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/minibossglow/minibossglow_plugins.config"

function init()
  effect.setParentDirectives("border=2;FF000075;00000000")
end
init = PluginLoader.add_plugin_loader("minibossglow", PLUGINS_PATH, init)

function update(dt)

end

function uninit()

end
