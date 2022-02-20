require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/activeitem/stances.lua"

require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH = "/items/active/unsorted/stunmine/stunmine_plugins.config"

function init()
  initStances()

  self.icons = config.getParameter("icons")

  if storage.triggered then
    item.consume(1)
  elseif storage.launched then
    activeItem.setInventoryIcon(self.icons.trigger)
    setStance("readyTrigger")
  else
    activeItem.setInventoryIcon(self.icons.full)
    setStance("idle")
  end
end
init = PluginLoader.add_plugin_loader("stunmine", PLUGINS_PATH, init)

function update(dt, fireMode, shiftHeld)
  updateStance(dt)

  if storage.projectileId and world.entityType(storage.projectileId) ~= "projectile" then
    item.consume(1)
    return
  end

  if fireMode == "primary" then
    if self.stanceName == "idle" then
      setStance("windup")
    elseif self.stanceName == "readyTrigger" then
      trigger()
    end
  end

  updateAim()
end

function launchMine()
  local pPos = firePosition()
  local pVec = aimVector()

  if not world.lineTileCollision(mcontroller.position(), pPos) then
    animator.playSound("throw")
    storage.projectileId = world.spawnProjectile(
          "stunmine",
          pPos,
          activeItem.ownerEntityId(),
          pVec,
          false,
          {
            speed = 30
          }
        )
  end

  if storage.projectileId then
    storage.launched = true
  end
end

function launchComplete()
  if storage.projectileId then
    activeItem.setInventoryIcon(self.icons.trigger)
    setStance("readyTrigger")
  else
    setStance("afterThrow")
  end
end

function trigger()
  storage.triggered = true
  setStance("trigger")
  animator.playSound("trigger")
  world.sendEntityMessage(storage.projectileId, "triggerRemoteDetonation")
end

function triggerComplete()
  item.consume(1)
end
