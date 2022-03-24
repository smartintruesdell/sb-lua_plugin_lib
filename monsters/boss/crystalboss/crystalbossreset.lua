-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/monsters/boss/crystalboss/crystalbossreset_plugins.config"] = true

function bossReset()
  animator.setAnimationState("eye", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("shell", "stage1")
  animator.setAnimationState("organs", "six")

  local moontants = world.entityQuery(mcontroller.position(), 60, { includedTypes = {"monster"} })
  for _,moontant in pairs(moontants) do
    if world.monsterType(moontant) == "moontant" then
      world.callScriptedEntity(moontant, "monster.setDropPool", nil)
      world.callScriptedEntity(moontant, "status.setResource", "health", 0)
    end
  end

  local switches = world.entityQuery(mcontroller.position(), 60, { includedTypes = {"object"} })
  for _,switch in pairs(switches) do
    if world.entityName(switch) == "smallwallswitchlit" then
      local switchState = world.callScriptedEntity(switch, "state")
      if switchState then
        world.callScriptedEntity(switch, "onInteraction")
      end
    end
  end
end
