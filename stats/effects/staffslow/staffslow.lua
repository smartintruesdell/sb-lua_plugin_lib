require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/staffslow/staffslow_plugins.config"

function init()
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.3}
  })
end
init = PluginLoader.add_plugin_loader("staffslow", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.4,
      speedModifier = 0.5,
      airJumpModifier = 0.7
    })
end

function uninit()

end
