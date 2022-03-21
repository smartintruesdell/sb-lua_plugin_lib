require "/scripts/rect.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/bed/bed_plugins.config"

function init()
  effect.addStatModifierGroup({{stat = "nude", amount = 1}, {stat = "foodDelta", effectiveMultiplier = 0}})
  if status.isResource("food") and not status.resourcePositive("food") then
    status.setResource("food", 0.01)
  end

  animator.setParticleEmitterOffsetRegion("healing", rect.rotate(mcontroller.boundBox(), mcontroller.rotation()))
  animator.setParticleEmitterActive("healing", true)

  script.setUpdateDelta(5)

  self.healingRate = 1.0 / config.getParameter("healTime", 60)
end
init = PluginLoader.add_plugin_loader("bed", PLUGINS_PATH, init)

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function uninit()

end
