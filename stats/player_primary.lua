require "/scripts/status.lua"
require "/scripts/achievements.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/stats/player_primary_plugins.config"

function init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.debug = true
  PluginLoader.load(PLUGINS_PATH)
  if plugin_init ~= nil then
    plugin_init()
  end
  -- END PLUGIN LOADER --------------------------------------------------------

  self.lastYPosition = 0
  self.lastYVelocity = 0
  self.fallDistance = 0
  self.hitInvulnerabilityTime = 0
  self.shieldHitInvulnerabilityTime = 0
  self.suffocateSoundTimer = 0
  self.ouchCooldown = 0

  init_set_ouch_noise()
  init_setup_damageListener()
  init_handlers()
end

function init_set_ouch_noise()
  local ouchNoise = status.statusProperty("ouchNoise")
  if ouchNoise then
    animator.setSoundPool("ouch", {ouchNoise})
  end
end

function init_setup_damageListener()
  self.inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)
end

function init_handlers()
  message.setHandler(
    "applyStatusEffect",
    function(_, _, effectConfig, duration, sourceEntityId)
      status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
    end
  )
end

function inflictedDamageCallback(notifications)
  for _,notification in ipairs(notifications) do
    inflictedDamageCallback_handle_notification(notification)
  end
end

function inflictedDamageCallback_handle_notification(notification)
  if notification.hitType == "Kill" then
    if world.entityExists(notification.targetEntityId) then
      inflictedDamageCallback_handle_killed_entity(notification)
    else
      -- TODO: better method for getting data on killed entities
      sb.logInfo(
        "Skipped event recording for nonexistent entity %s",
        notification.targetEntityId
      )
    end
  end
end

function inflictedDamageCallback_handle_killed_entity(notification)
  local entityType = world.entityType(notification.targetEntityId)
  local eventFields = entityEventFields(notification.targetEntityId)
  util.mergeTable(eventFields, worldEventFields())
  eventFields.damageSourceKind = notification.damageSourceKind

  if entityType == "object" then
    recordEvent(entity.id(), "killObject", eventFields)

  elseif
    entityType == "npc" or
    entityType == "monster" or
    entityType == "player"
  then
    recordEvent(entity.id(), "kill", eventFields)
  end

  if entityType == "monster" then
    local monsterClass =
      root.monsterParameters(eventFields.monsterType).monsterClass or "standard"

    recordEvent(entity.id(), "killMonster", {monsterClass = monsterClass})
  end
end

DamageFnByDamageType = {
  Damage = applyDamageRequest_get_damage_with_protection,
  Knockback = applyDamageRequest_get_damage_with_protection,
  IgnoresDef = applyDamageRequest_get_damage_without_protection,
  Environment = applyDamageRequest_get_damage_without_protection,
  default = function() return 0 end
}
HealthLossFnByDamageType = {
  Knockback = function() return end,
  default = applyDamageRequest_apply_health_lost
}

function applyDamageRequest(damageRequest)
  if applyDamageRequest_player_is_invulnerable(damageRequest) then
    return {}
  end

  applyDamageRequest_apply_status_effects(damageRequest)
  if
    damageRequest.damageSourceKind == "applystatus" or
    damageRequest.damageType == "Status"
  then
    return {}
  end

  -- Base damage by damageType
  local damage = nil
  if DamageFnByDamageType[damageRequest.damageType] ~= nil then
    damage = DamageFnByDamageType[damageRequest.damageType](damageRequest)
  else
    damage = DamageFnByDamageType.default(damageRequest)
  end
  -- Damage Absorbtion
  damage = applyDamageRequest_apply_damage_absorbtion(damage, damageRequest)
  -- Damage reduction from shields
  damage, damageRequest = applyDamageRequest_apply_shield(damage, damageRequest)
  -- Damage reduction from resistances
  damage = applyDamageRequest_apply_elemental_resistances(damage, damageRequest)

  local health_lost = math.min(damage, status.resource("health"))
  if health_lost > 0 then
    if HealthLossFnByDamageType[damageRequest.damageType] ~= nil then
      HealthLossFnByDamageType[damageRequest.damageType](
        health_lost,
        damage,
        damageRequest
      )
    else
      HealthLossFnByDamageType.default(
        health_lost,
        damage,
        damageRequest
      )
    end
  end

  applyDamageRequest_apply_knockback(damageRequest)

  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = health_lost,
    hitType = applyDamageRequest_update_hit_type(damageRequest),
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = status.statusProperty("targetMaterialKind")
  }}
end

function applyDamageRequest_player_is_invulnerable(damageRequest)
  local hitInvulnerability =
    self.hitInvulnerabilityTime > 0 and
    damageRequest.damageSourceKind ~= "applystatus"

  return world.getProperty("invinciblePlayers") or (
    damageRequest.damageSourceKind ~= "falling" and
    (hitInvulnerability or world.getProperty("nonCombat"))
  )
end

function applyDamageRequest_apply_status_effects(damageRequest)
  status.addEphemeralEffects(
    damageRequest.statusEffects,
    damageRequest.sourceEntityId
  )
end

function applyDamageRequest_get_damage_with_protection(damageRequest)
  return root.evalFunction2(
    "protection",
    damageRequest.damage,
    status.stat("protection")
  )
end

function applyDamageRequest_get_damage_without_protection(damageRequest)
  return damageRequest.damage
end

function applyDamageRequest_apply_damage_absorbtion(damage)
  if status.resourcePositive("damageAbsorption") then
    local damageAbsorb = math.min(damage, status.resource("damageAbsorption"))
    status.modifyResource("damageAbsorption", -damageAbsorb)
    return damage - damageAbsorb
  end
  return damage
end

function applyDamageRequest_apply_shield(damage, damageRequest)
  if damageRequest.hitType == "ShieldHit" then
    if self.shieldHitInvulnerabilityTime == 0 then
      local preShieldDamageHealthPercentage = damage / status.resourceMax("health")
      self.shieldHitInvulnerabilityTime =
        status.statusProperty("shieldHitInvulnerabilityTime") *
        math.min(preShieldDamageHealthPercentage, 1.0)

      if not status.resourcePositive("perfectBlock") then
        status.modifyResource("shieldStamina", -damage / status.stat("shieldHealth"))
      end
    end

    status.setResourcePercentage("shieldStaminaRegenBlock", 1.0)
    damage = 0
    damageRequest.statusEffects = {}
    damageRequest.damageSourceKind = "shield"
  end
  return damage, damageRequest
end

function applyDamageRequest_apply_elemental_resistances(damage, damageRequest)
  local elementalStat = root.elementalResistance(damageRequest.damageSourceKind)
  local resistance = status.stat(elementalStat)
  return damage - (resistance * damage)
end

function applyDamageRequest_apply_health_lost(health_lost, damage)
  status.modifyResource("health", -health_lost)
  if self.ouchCooldown <= 0 then
    animator.playSound("ouch")
    self.ouchCooldown = 0.5
  end

  applyDamageRequest_apply_invulnerability_frames(damage)
end

function applyDamageRequest_apply_invulnerability_frames(damage)
  local damageHealthPercentage = damage / status.resourceMax("health")
  if
    damageHealthPercentage > status.statusProperty("hitInvulnerabilityThreshold")
  then
    self.hitInvulnerabilityTime = status.statusProperty("hitInvulnerabilityTime")
  end
end

function applyDamageRequest_apply_knockback(damageRequest)
  local knockbackFactor = (1 - status.stat("grit"))

  local knockbackMomentum = vec2.mul(damageRequest.knockbackMomentum, knockbackFactor)
  local knockback = vec2.mag(knockbackMomentum)
  if knockback > status.stat("knockbackThreshold") then
    mcontroller.setVelocity({0,0})
    local dir = knockbackMomentum[1] > 0 and 1 or -1
    mcontroller.addMomentum({dir * knockback / 1.41, knockback / 1.41})
  end
end

function applyDamageRequest_update_hit_type(damageRequest)
  if not status.resourcePositive("health") then
    return "kill"
  end
  return damageRequest.hitType
end

function notifyResourceConsumed(resourceName, amount)
  if resourceName == "energy" and amount > 0 then
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end
end

function update(dt)
  update_apply_fall_damage(dt)
  update_apply_breathing(dt)
  update_apply_invulnerability_frames(dt)
  update_apply_energy_regen(dt)
  update_apply_shield_regen(dt)
  self.inflictedDamage:update(dt)
  update_apply_world_limit(dt)
end

function update_apply_fall_damage(dt)
  local minimumFallDistance = 14
  local fallDistanceDamageFactor = 3
  local minimumFallVel = 40
  local baseGravity = 80
  local gravityDiffFactor = 1 / 30.0

  local curYPosition = mcontroller.yPosition()
  local yPosChange = curYPosition - (self.lastYPosition or curYPosition)

  self.ouchCooldown = math.max(0.0, self.ouchCooldown - dt)

  if self.fallDistance > minimumFallDistance and -self.lastYVelocity > minimumFallVel and mcontroller.onGround() then
    local damage = (self.fallDistance - minimumFallDistance) * fallDistanceDamageFactor
    damage = damage * (1.0 + (world.gravity(mcontroller.position()) - baseGravity) * gravityDiffFactor)
    damage = damage * status.stat("fallDamageMultiplier")
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = damage,
        damageSourceKind = "falling",
        sourceEntityId = entity.id()
      })
  end

  if mcontroller.yVelocity() < -minimumFallVel and not mcontroller.onGround() then
    self.fallDistance = self.fallDistance + -yPosChange
  else
    self.fallDistance = 0
  end

  self.lastYPosition = curYPosition
  self.lastYVelocity = mcontroller.yVelocity()
end

function update_apply_breathing(dt)
  local mouthPosition = vec2.add(
    mcontroller.position(),
    status.statusProperty("mouthPosition")
  )
  if
    status.statPositive("breathProtection") or
    world.breathable(mouthPosition)
  then
    status.modifyResource("breath", status.stat("breathRegenerationRate") * dt)
  else
    status.modifyResource("breath", -status.stat("breathDepletionRate") * dt)
  end

  if not status.resourcePositive("breath") then
    self.suffocateSoundTimer = self.suffocateSoundTimer - dt
    if self.suffocateSoundTimer <= 0 then
      self.suffocateSoundTimer = 0.5 + (0.5 * status.resourcePercentage("health"))
      animator.playSound("suffocate")
    end
    status.modifyResourcePercentage(
      "health",
      -status.statusProperty("breathHealthPenaltyPercentageRate") * dt
    )
  else
    self.suffocateSoundTimer = 0
  end
end

function update_apply_invulnerability_frames(dt)
  self.hitInvulnerabilityTime = math.max(self.hitInvulnerabilityTime - dt, 0)
  local flashTime = status.statusProperty("hitInvulnerabilityFlash")

  if self.hitInvulnerabilityTime > 0 then
    if math.fmod(self.hitInvulnerabilityTime, flashTime) > flashTime / 2 then
      status.setPrimaryDirectives(status.statusProperty("damageFlashOffDirectives"))
    else
      status.setPrimaryDirectives(status.statusProperty("damageFlashOnDirectives"))
    end
  else
    status.setPrimaryDirectives()
  end
end

function update_apply_energy_regen(dt)
  if status.resourceLocked("energy") and status.resourcePercentage("energy") == 1 then
    animator.playSound("energyRegenDone")
  end

  if status.resource("energy") == 0 then
    if not status.resourceLocked("energy") then
      animator.playSound("outOfEnergy")
      animator.burstParticleEmitter("outOfEnergy")
    end

    status.setResourceLocked("energy", true)
  elseif status.resourcePercentage("energy") == 1 then
    status.setResourceLocked("energy", false)
  end

  if not status.resourcePositive("energyRegenBlock") then
    status.modifyResourcePercentage(
      "energy",
      status.stat("energyRegenPercentageRate") * dt
    )
  end
end

function update_apply_shield_regen(dt)
  self.shieldHitInvulnerabilityTime = math.max(
    self.shieldHitInvulnerabilityTime - dt,
    0
  )

  if not status.resourcePositive("shieldStaminaRegenBlock") then
    status.modifyResourcePercentage(
      "shieldStamina",
      status.stat("shieldStaminaRegen") * dt
    )
    status.modifyResourcePercentage(
      "perfectBlockLimit",
      status.stat("perfectBlockLimitRegen") * dt
    )
  end
end

function update_apply_world_limit(dt)
  if mcontroller.atWorldLimit(true) then
    status.setResourcePercentage("health", 0)
  end
end

function overheadBars()
  local bars = {}

  if status.statPositive("shieldHealth") then
    table.insert(bars, {
      percentage = status.resource("shieldStamina"),
      color = status.resourcePositive("perfectBlock") and {255, 255, 200, 255} or {200, 200, 0, 255}
    })
  end

  return bars
end
