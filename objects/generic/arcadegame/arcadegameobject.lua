require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/generic/arcadegame/arcadegameobject_plugins.config"

function init()
  message.setHandler("youwin", function()
      world.spawnItem(config.getParameter("winningItem"), vec2.add(object.position(), {0, 3}))
    end)
end
init = PluginLoader.add_plugin_loader("arcadegameobject", PLUGINS_PATH, init)
