require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/vehicles/dropship/dropship.lua"
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/vehicles/dropship/dropshipcontrol_plugins.config"

function init()
  initShip()

  self.lastAltFire = false
end
init = PluginLoader.add_plugin_loader("dropshipcontrol", PLUGINS_PATH, init)

function update(dt)
  local moveDir = {0, 0}
  if vehicle.controlHeld("seat", "right") then
    moveDir[1] = moveDir[1] + 1
  end
  if vehicle.controlHeld("seat", "left") then
    moveDir[1] = moveDir[1] - 1
  end
  if vehicle.controlHeld("seat", "up") then
    moveDir[2] = moveDir[2] + 1
  end
  if vehicle.controlHeld("seat", "down") then
    moveDir[2] = moveDir[2] - 1
  end

  if vehicle.controlHeld("seat", "primaryFire") then
    startFiring()
  else
    stopFiring()
  end

  local altFire = vehicle.controlHeld("seat", "altFire")
  if altFire and not self.lastAltFire then
    toggleBlinds()
  end
  self.lastAltFire = altFire

  local driver = vehicle.entityLoungingIn("seat")
  updateShip(dt, driver, moveDir)
end
