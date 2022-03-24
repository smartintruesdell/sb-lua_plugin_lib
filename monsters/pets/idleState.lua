require "/scripts/util.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/pets/idleState_plugins.config"] = true

idleState = {}

function idleState.enter()
  local idleTime = util.randomInRange(config.getParameter("idle.idleTime"))
  return {
    idleTime = idleTime,
    timer = idleTime,
  }
end

function idleState.enteringState(stateData)
end

function idleState.update(dt, stateData)
  stateData.timer = stateData.timer - dt

  setIdleState()

  if stateData.timer < 0 then
    return true, 1
  else
    return false
  end
end
