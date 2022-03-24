require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/monsters/boss/ophanim/ophanimbeam_plugins.config"

function init()
  self.colors = {
    {255, 128, 0, 255},
    {255, 128, 0, 255}
  }
  self.flashTimers = {
    0.0,
    0.0
  }
end
init = PluginLoader.add_plugin_loader("ophanimbeam", PLUGINS_PATH, init)

function update()
  localAnimator.clearDrawables()
  local targets = animationConfig.animationParameter("beamTargets") or {}
  for i, targetId in ipairs(targets) do
    if world.entityExists(targetId) then
      local toTarget = world.distance(world.entityPosition(targetId), entity.position())

      self.flashTimers[i] = self.flashTimers[i] - script.updateDt()
      if self.flashTimers[i] < 0.0 then
        local queryStart = entity.position()
        local queryEnd = vec2.add(entity.position(), toTarget)
        local players = world.entityLineQuery(queryStart, queryEnd, {includedTypes = {"vehicle"}, boundMode = "CollisionArea"})
        if #players > 0 then
          self.colors[i] = {255, 255, 255, 255}
        else
          self.colors[i] = {255, 128, 0, 255}
        end
        self.flashTimers[i] = 0.25
      end

      localAnimator.addDrawable({
        line = {{0, 0}, toTarget},
        width = 2.0,
        position = entity.position(),
        color = self.colors[i],
        fullbright = true
      }, "Projectile-30")
    end
  end
end
