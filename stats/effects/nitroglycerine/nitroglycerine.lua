require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/nitroglycerine/nitroglycerine_plugins.config"

function init()
  self.maxDV = 30

  self.blinkTimer = 1.0
  self.lastSpeed = world.magnitude(mcontroller.velocity())
end
init = PluginLoader.add_plugin_loader("nitroglycerine", PLUGINS_PATH, init)

function update(dt)
  self.newSpeed = world.magnitude(mcontroller.velocity())

  self.blinkTimer = self.blinkTimer - dt
  if self.blinkTimer <= 0 then self.blinkTimer = 1.0 end

  if self.blinkTimer < 0.2 or self.newSpeed > self.maxDV then
    effect.setParentDirectives("fade=FF0000;0.4")
  else
    effect.setParentDirectives("")
  end

  if math.abs(self.lastSpeed - self.newSpeed) > self.maxDV then
    world.spawnProjectile("zbomb", mcontroller.position(), 0, {0, 0}, false, { timeToLive = 0 })
  end

  self.lastSpeed = self.newSpeed
end

function uninit()

end
