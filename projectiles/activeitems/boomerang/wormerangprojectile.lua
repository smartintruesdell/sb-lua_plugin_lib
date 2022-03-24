require "/scripts/vec2.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/projectiles/boomerang/wormerangprojectile_plugins.config"

boomerangExtra = {}

function boomerangExtra:init()
  self.wobbleTimer = 0
  self.wobbleRate = config.getParameter("wobbleRate")
  self.wobbleIntensity = config.getParameter("wobbleIntensity")
end
boomerangExtra.init = PluginLoader.add_plugin_loader("wormerangprojectile", PLUGINS_PATH, boomerangExtra.init)

function boomerangExtra:update(dt)
  self.wobbleTimer = self.wobbleTimer + (self.wobbleRate * math.pi * dt)

  mcontroller.setVelocity(vec2.rotate(mcontroller.velocity(), self.wobbleIntensity * dt * math.cos(self.wobbleTimer)))
end
