require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/techstun/techstun_plugins.config"

function init()
  effect.setParentDirectives("fade=f915cf=0.4")

  doStun()
end
init = PluginLoader.add_plugin_loader("techstun", PLUGINS_PATH, init)

function update(dt)
  doStun()
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function doStun()
  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration() or 0.1))
  end
  mcontroller.setVelocity({0, 0})
end
