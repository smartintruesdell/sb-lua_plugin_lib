require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/partytime/partytime_plugins.config"

function init()
  self.timers = {}
  for i = 1, 4 do
    self.timers[i] = math.random() * 2 * math.pi
  end

  script.setUpdateDelta(3)
end
init = PluginLoader.add_plugin_loader("partytime", PLUGINS_PATH, init)

function update(dt)
  for i = 1, 4 do
    self.timers[i] = self.timers[i] + dt
    if self.timers[i] > (2 * math.pi) then self.timers[i] = self.timers[i] - 2 * math.pi end

    local lightAngle = math.cos(self.timers[i]) * 120 + (i * 90)
    animator.setLightPointAngle("light"..i, lightAngle)
  end
end

function uninit()

end
