-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/fishing/appearState_plugins.config"] = true

appearState = {}

function appearState.enter()
  if storage.stateStage == "appear" then return {} end
end

function appearState.enteringState(stateData)
  animator.setAnimationState("movement", "swimSlow")
end

function appearState.update(dt, stateData)
  self.targetOpacity = 1

  if self.currentOpacity == 1 then
    storage.stateStage = "approach"
    return true
  end

  move(self.toLure, self.swimSpeed)

  return false
end

function appearState.leavingState(stateData)

end
