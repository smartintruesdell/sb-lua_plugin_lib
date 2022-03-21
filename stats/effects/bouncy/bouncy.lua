require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/bouncy/bouncy_plugins.config"

function init()
  effect.setParentDirectives("border=2;0088FF99;00000000")
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})
end
init = PluginLoader.add_plugin_loader("bouncy", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlParameters({
      bounceFactor = 0.95
    })
end

function uninit()

end
