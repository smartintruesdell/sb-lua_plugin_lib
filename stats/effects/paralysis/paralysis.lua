require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/paralysis/paralysis_plugins.config"

function init()
  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
  mcontroller.setVelocity({0, 0})
end
init = PluginLoader.add_plugin_loader("paralysis", PLUGINS_PATH, init)

function update(dt)
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function uninit()

end
