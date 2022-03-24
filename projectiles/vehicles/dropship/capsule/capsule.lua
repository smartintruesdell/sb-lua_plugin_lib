require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/vehicles/dropship/capsule/capsule_plugins.config"

function init() end
init = PluginLoader.add_plugin_loader("capsule", PLUGINS_PATH, init)

function destroy()
  local objectType = ({
    "capsulesmall",
    "capsulemed",
    "capsulebig"
  })[math.random(1, 3)]
  local places = world.placeObject(objectType, vec2.floor(entity.position()), 1)
end
