require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/jumpboost/jumpboost20_plugins.config"

function init()
  local bounds = mcontroller.boundBox()
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = 0.2}
  })
end
init = PluginLoader.add_plugin_loader("jumpboost20", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      airJumpModifier = 1.20
    })
end

function uninit()

end
