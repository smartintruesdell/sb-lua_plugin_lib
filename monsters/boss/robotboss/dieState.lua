-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/boss/robotboss/dieState_plugins.config"] = true

dieState = {}

function dieState.enterWith(args)
  if not args.die then return nil end

  return {
    timer = 1.0
  }
end

function dieState.enteringState(stateData)
  world.spawnNpc(mcontroller.position(), "penguin", "penguinscientist", 1)

  local players = world.players()
  for _,playerId in pairs(players) do
    world.sendEntityMessage(playerId, "shockhopperDeath")
  end
end

function dieState.update(dt, stateData)
  if stateData.timer <= 0.0 then
    self.dead = true
  end

  stateData.timer = stateData.timer - dt
  return false
end
