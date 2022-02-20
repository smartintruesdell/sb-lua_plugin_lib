require "/vehicles/modularmech/armscripts/base.lua"

require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH = "/vehicles/modularmech/armscripts/despawnarm_plugins.config"

DespawnArm = MechArm:extend()

DespawnArm.init = PluginLoader.add_plugin_loader("despawnarm", PLUGINS_PATH, DespawnArm.init)

function DespawnArm:update(dt, firing, edgeTrigger, aimPosition, facingDirection)
  if firing and edgeTrigger then
    vehicle.destroy()
  end
end
