require "/scripts/util.lua"
require "/scripts/vec2.lua"

require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH = "/items/active/unsorted/broom/broom_plugins.config"

function init()
  self.idleArmAngle = config.getParameter("idleArmAngle", -0.5)
  self.idleBroomAngle = config.getParameter("idleBroomAngle", 0.2)
  self.windupTime = config.getParameter("windupTime", 0.1)
  self.sweepTime = config.getParameter("sweepTime", 0.2)
  self.sweepArmAngle = config.getParameter("sweepArmAngle", {-0.5, 0.0})
  self.sweepBroomAngle = config.getParameter("sweepBroomAngle", {0.2, 0.4})
  self.sweepBackTime = config.getParameter("sweepBackTime", 0.1)

  idle()
end
init = PluginLoader.add_plugin_loader("broom", PLUGINS_PATH, init)

function activate(fireMode, shiftHeld)
  if self.state == "idle" then
    windup()
  end
end

function update(dt, fireMode, shiftHeld)
  self.stateTimer = math.max(0, self.stateTimer - dt)

  if self.state == "idle" then

  end

  if self.state == "windup" then
    if self.stateTimer == 0 then
      sweep()
    end
  end

  if self.state == "sweep" then
    if self.stateTimer == 0 then
      sweepBack()
    else
      local sweepRatio = 1 - (self.stateTimer / self.sweepTime)
      activeItem.setArmAngle(util.lerp(sweepRatio, self.sweepArmAngle))
      animator.resetTransformationGroup("broom")
      animator.rotateTransformationGroup("broom", util.lerp(sweepRatio, self.sweepBroomAngle))
    end
  end

  if self.state == "sweepback" then
    if self.stateTimer == 0 then
      if fireMode ~= "none" then
        sweep()
      else
        idle()
      end
    else
      local sweepRatio = self.stateTimer / self.sweepTime
      activeItem.setArmAngle(util.lerp(sweepRatio, self.sweepArmAngle))
      animator.resetTransformationGroup("broom")
      animator.rotateTransformationGroup("broom", util.lerp(sweepRatio, self.sweepBroomAngle))
    end
  end
end

function uninit()

end

function idle()
  self.state = "idle"
  self.stateTimer = 0
  activeItem.setArmAngle(self.idleArmAngle)
  activeItem.setTwoHandedGrip(false)
  animator.resetTransformationGroup("broom")
  animator.rotateTransformationGroup("broom", self.idleBroomAngle)
end

function windup()
  self.state = "windup"
  self.stateTimer = self.windupTime
  activeItem.setTwoHandedGrip(true)
end

function sweep()
  self.state = "sweep"
  self.stateTimer = self.sweepTime
  animator.playSound("sweep")
  animator.burstParticleEmitter("dust")
  activeItem.setTwoHandedGrip(true)
end

function sweepBack()
  self.state = "sweepback"
  self.stateTimer = self.sweepBackTime
  activeItem.setTwoHandedGrip(true)
end
