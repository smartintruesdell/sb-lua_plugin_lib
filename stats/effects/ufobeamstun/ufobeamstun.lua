require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/ufobeamstun/ufobeamstun_plugins.config"

function init()
  effect.setParentDirectives("fade=60b8ea=0.4")
  animator.setAnimationRate(0)
  effect.addStatModifierGroup({
    {stat = "fireStatusImmunity", amount = 1},
    {stat = "iceStatusImmunity", amount = 1},
    {stat = "electricStatusImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
    {stat = "powerMultiplier", effectiveMultiplier = 0}
  })
end
init = PluginLoader.add_plugin_loader("ufobeamstun", PLUGINS_PATH, init)

function update(dt)
  status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function onExpire()
  animator.setAnimationRate(1)
end
