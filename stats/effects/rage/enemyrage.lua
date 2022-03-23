require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/rage/enemyrage_plugins.config"

function init()
  --Power
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})

  --Colour
  effect.setParentDirectives("fade="..config.getParameter("color").."=0.5")
  script.setUpdateDelta(0)

  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", true)
end
init = PluginLoader.add_plugin_loader("enemyrage", PLUGINS_PATH, init)


function update(dt)

end

function uninit()

end
