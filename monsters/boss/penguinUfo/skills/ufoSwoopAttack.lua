-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/boss/penguinUfo/skills/ufoSwoopAttack_plugins.config"] = true

ufoSwoopAttack = {}

function ufoSwoopAttack.enter()
  if not hasTarget() then return nil end
  if self.targetPosition == nil then return nil end

  return {
    timer = 0.0,
    swoopTime = config.getParameter("ufoSwoopAttack.swoopTime"),
    tookDamage = false
  }
end

function ufoSwoopAttack.enteringState(stateData)
  monster.setActiveSkillName("ufoSwoopAttack")
end

function ufoSwoopAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local position = mcontroller.position()
  if stateData.basePosition == nil then
    stateData.basePosition = { self.targetPosition[1], position[2] }
    stateData.toTarget = world.distance(vec2.add(self.targetPosition, {0, 4.0}), position)

    monster.setDamageOnTouch(true)
  end

  stateData.timer = stateData.timer + dt

  local timerRatio = stateData.timer / stateData.swoopTime
  local angle = timerRatio * math.pi
  local targetPosition = {
    stateData.basePosition[1] - math.cos(angle) * stateData.toTarget[1],
    stateData.basePosition[2] + math.sin(angle) * stateData.toTarget[2]
  }
  local toTarget = world.distance(targetPosition, mcontroller.position())
  mcontroller.setVelocity(vec2.mul(toTarget, 1 / dt))

  if stateData.timer > stateData.swoopTime or checkWalls(util.toDirection(toTarget[1])) then
    return true
  else
    return false
  end
end


function ufoSwoopAttack.leavingState(stateData)
  monster.setDamageOnTouch(false)
end
