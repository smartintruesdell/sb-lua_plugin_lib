-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/boss/penguinUfo/idleState_plugins.config"] = true

idleState = {}

function idleState.enter()
  if hasTarget() then return nil end

  return {
    timer = 0,
    bobInterval = 4,
    bobHeight = 2
  }
end

function idleState.update(dt, stateData)
  mcontroller.controlFace(1)
  stateData.timer = stateData.timer + dt
  if stateData.timer > stateData.bobInterval then
    stateData.timer = stateData.timer - stateData.bobInterval
  end

  local bobOffset = math.sin((stateData.timer / stateData.bobInterval) * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
