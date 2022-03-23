require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/monsters/boss/guardianminion/minionline_plugins.config"

function init()
end
init = PluginLoader.add_plugin_loader("minionline", PLUGINS_PATH, init)

function update()
  localAnimator.clearDrawables()
  local targetId = animationConfig.animationParameter("targetId")
  if targetId and world.entityExists(targetId) then
    local toTarget = world.distance(world.entityPosition(targetId), entity.position())
    local mag = math.min(50, math.max(10, world.magnitude(toTarget)))
    localAnimator.addDrawable({line = {{0, 0}, toTarget}, width = math.max(1.0, 3.0 * (50 - mag) / 50), position = entity.position(), color = {164, 81, 196, 180}}, "Monster-10");
  end
end
