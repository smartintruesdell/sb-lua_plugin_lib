require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/objects/holiday/giftmonsterbox/giftmonsterbox_plugins.config"

function init()
  self.placed = true
end
init = PluginLoader.add_plugin_loader("giftmonsterbox", PLUGINS_PATH, init)

function update(dt)
  if self.placed then
    world.spawnMonster(config.getParameter("monsterType"), object.position())
    object.smash()
  end
end
