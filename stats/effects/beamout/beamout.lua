require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/beamout/beamout_plugins.config"

function init()
  animator.setAnimationState("teleport", "beamOut")
  effect.setParentDirectives("?multiply=ffffff00")
  animator.setGlobalTag("effectDirectives", status.statusProperty("effectDirectives", ""))

  local speciesTags = config.getParameter("speciesTags")
  if status.statusProperty("species") then
    animator.setGlobalTag("species", speciesTags[status.statusProperty("species")] or "")
  end

  self.triggerTimer = config.getParameter("triggerTime")
end
init = PluginLoader.add_plugin_loader("beamout", PLUGINS_PATH, init)

function update(dt)
  if self.triggerTimer > 0 then
    self.triggerTimer = self.triggerTimer - dt
    if self.triggerTimer <= 0 then
      trigger()
    end
  end
end

function trigger()
  if config.getParameter("teleport") then
    world.callScriptedEntity(entity.id(), "performTeleport")
    world.callScriptedEntity(entity.id(), "notify", { type = "performTeleport"})
    status.addEphemeralEffect("beamin")
  end
  if config.getParameter("die") then
    status.setResource("health", 0)
  end
end
