require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/biomecold/biomecold_plugins.config"

function init()
  animator.setParticleEmitterOffsetRegion("snow", mcontroller.boundBox())
  animator.setParticleEmitterActive("snow", true)

  effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)

  script.setUpdateDelta(config.getParameter("tickRate", 1))

  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = 0}})

  world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomecold", 5.0)
end
init = PluginLoader.add_plugin_loader("biomecold", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers(self.movementModifiers)
  if not status.overConsumeResource("energy", self.energyCost) then
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.healthDamage,
        damageSourceKind = "ice",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()

end
