require "/scripts/rect.lua"
require "/scripts/vec2.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/items/active/unsorted/railplatform/railplatform_plugins.config"

function init()
  self.placementRange = config.getParameter("placementRange")
  self.placementBounds = config.getParameter("placementBounds")
  self.previewOffset = config.getParameter("previewOffset", {0, 0})
  self.platformType = config.getParameter("platformType")
  activeItem.setScriptedAnimationParameter("previewImage", config.getParameter("placementPreviewImage"))
end
init = PluginLoader.add_plugin_loader("railplatform", PLUGINS_PATH, init)

function activate(fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  if placementValid(placePos) then
    world.spawnVehicle(self.platformType, placePos, {initialFacing = mcontroller.facingDirection()})
    item.consume(1)
  end
end

function update(dt, fireMode, shiftHeld)
  local placePos = activeItem.ownerAimPosition()
  activeItem.setScriptedAnimationParameter("previewPosition", vec2.add(placePos, self.previewOffset))
  activeItem.setScriptedAnimationParameter("previewValid", placementValid(placePos))

  local aimAngle, aimDirection = activeItem.aimAngleAndDirection(0, placePos)
  activeItem.setFacingDirection(aimDirection)
end

function placementValid(pos)
  if world.isTileProtected(pos) then return false end

  if world.magnitude(mcontroller.position(), pos) > self.placementRange then return false end

  if world.lineCollision(mcontroller.position(), pos, {"Null", "Block", "Dynamic", "Slippery"}) then return false end

  local placementRect = rect.translate(self.placementBounds, pos)
  return not world.rectCollision(placementRect, {"Null", "Block", "Dynamic", "Slippery"})
end
