require "/scripts/util.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/fishing/outOfWaterState_plugins.config"] = true

outOfWaterState = {}

function outOfWaterState.enter()
  if not self.inLiquid and storage.stateStage ~= "landed" and storage.stateStage ~= "hooked" then
    return {
      suffocateTimer = 2
    }
  end
end

function outOfWaterState.enteringState(stateData)
  animator.setAnimationState("movement", "panicSlow")
  setBodyDirection({mcontroller.facingDirection(), 0})
end

function outOfWaterState.update(dt, stateData)
  if self.inLiquid then return true end

  stateData.suffocateTimer = stateData.suffocateTimer - dt
  if stateData.suffocateTimer <= 0 or mcontroller.onGround() then
    monster.setDeathSound("deathPuff")
    monster.setDeathParticleBurst(config.getParameter("deathParticles"))
    status.setResource("health", 0)
    return false
  end

  return false
end

function outOfWaterState.leavingState(stateData)

end
