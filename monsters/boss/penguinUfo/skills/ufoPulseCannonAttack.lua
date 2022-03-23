-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/boss/penguinUfo/skills/ufoPulseCannonAttack_plugins.config"] = true

--------------------------------------------------------------------------------
ufoPulseCannonAttack = {}

function ufoPulseCannonAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("ufoPulseCannonAttack.projectile.type"), config.getParameter("ufoPulseCannonAttack.projectile.config"), 0.2)

  local toTarget = world.distance(self.targetPosition, mcontroller.position())
  return {
    basePosition = self.spawnPosition,
    direction = util.randomDirection(),
    cruiseDistance = config.getParameter("cruiseDistance"),
    firing = false
  }
end

function ufoPulseCannonAttack.enteringState(stateData)
  monster.setActiveSkillName("ufoPulseCannonAttack")
end

function ufoPulseCannonAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end
  local position = mcontroller.position()

  if not stateData.firing then
    local targetPosition = {
      self.targetPosition[1] + stateData.direction * stateData.cruiseDistance,
      stateData.basePosition[2]
    }
    flyTo(targetPosition)

    local targetDistance = world.magnitude(targetPosition, mcontroller.position())
    if targetDistance < 2 or checkWalls(stateData.direction) then
      stateData.firing = true
    end
  else
    rangedAttack.fireContinuous(true)
    local targetPosition = {
      self.targetPosition[1] - stateData.direction * stateData.cruiseDistance,
      stateData.basePosition[2]
    }
    flyTo(targetPosition)

    local targetDistance = world.magnitude(targetPosition, mcontroller.position())
    if targetDistance < 2 or checkWalls(-stateData.direction) then
      return true
    end
  end

  return false
end

function ufoPulseCannonAttack.leavingState(stateData)
  rangedAttack.stopFiring()
end
