require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/beamin/beamin_plugins.config"

function init()
  animator.setAnimationState("teleport", "beamIn")
  effect.setParentDirectives("?multiply=ffffff00")
  animator.setGlobalTag("effectDirectives", status.statusProperty("effectDirectives", ""))

  local speciesTags = config.getParameter("speciesTags")
  if status.statusProperty("species") then
    animator.setGlobalTag("species", speciesTags[status.statusProperty("species")] or "")
  end

  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
end
init = PluginLoader.add_plugin_loader("beamin", PLUGINS_PATH, init)

function update(dt)
  effect.setParentDirectives(string.format("?multiply=%s", animator.animationStateProperty("teleport", "multiply")))
end
