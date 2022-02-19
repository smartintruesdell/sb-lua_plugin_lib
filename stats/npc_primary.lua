require "/scripts/vec2.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/stats/npc_primary_plugins.config"

-- Module initialization ------------------------------------------------------

function init()

  self.damageFlashTime = 0
  self.hitInvulnerabilityTime = 0

  message.setHandler("applyStatusEffect", applyStatusEffectCallback)

end

init = PluginLoader.add_plugin_loader("npc_primary", PLUGINS_PATH, init)

-- Event Handlers -------------------------------------------------------------

function applyStatusEffectCallback(_, _, effectConfig, duration, sourceEntityId)
  status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
end

-- applyDamageRequest : handles incoming hits ---------------------------------

--- Determines the correct damage for an attack that is mitigated by protection
function applyDamageRequest_get_damage_with_protection(damageRequest)
  return root.evalFunction2(
    "protection",
    damageRequest.damage,
    status.stat("protection")
  )
end

--- Determines the correct damage for an attack that ignores protection
function applyDamageRequest_get_damage_without_protection(damageRequest)
  return damageRequest.damage
end

--- A Map<DamageType, Function> used to determine the correct damage function
DamageFnByDamageType = {
  ["Damage"] = applyDamageRequest_get_damage_with_protection,
  ["Knockback"] = applyDamageRequest_get_damage_with_protection,
  ["IgnoresDef"] = applyDamageRequest_get_damage_without_protection,
  ["Environment"] = applyDamageRequest_get_damage_without_protection,
  default = function() return 0 end
}

--- Applies damage dealt to this entity
function applyDamageRequest_apply_health_lost(health_lost, damage, _damageRequest)
  status.modifyResource("health", -health_lost)

  applyDamageRequest_apply_invulnerability_frames(damage)
end

--- A Map<DamageType, function> used to determine the correct health loss function
HealthLossFnByDamageType = {
  Knockback = function() return end,
  default = applyDamageRequest_apply_health_lost
}

--- An engine supplied event listener that catches incoming damage requests (hits)
function applyDamageRequest(damageRequest)
  -- Early out if the entity is invulnerable
  if applyDamageRequest_entity_is_invulnerable(damageRequest) then return {} end

  -- Early out for status-only attacks
  if
    damageRequest.damageSourceKind == "applystatus" or
    damageRequest.damageType == "Status"
  then
    applyDamageRequest_apply_status_effects(damageRequest)
    return {}
  end

  -- Early out if environment damage doesn't apply
  if
    damageRequest.damageType == "Environment" and
    not applyDamageRequest_should_apply_environment_damage()
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
  damage, damageRequest = applyDamageRequest_apply_damage_absorbtion(
    damage,
    damageRequest
  )
  -- Damage reduction from shields
  damage, damageRequest = applyDamageRequest_apply_shield(
    damage,
    damageRequest
  )
  -- Damage reduction from resistances
  damage, effectiveness, damageRequest =
    applyDamageRequest_apply_elemental_resistances(
      damage,
      damageRequest
    )

  -- Shield or resistances may have nullified status effects, so we apply them here.
  applyDamageRequest_apply_status_effects(damageRequest)

  -- Apply result damage to the entity's health
  local health_lost = math.min(damage, status.resource("health"))
  if health_lost > 0 then
    applyDamageRequest_apply_damageFlashType(effectiveness, damageRequest)
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

  -- Apply knockback to the entity
  applyDamageRequest_apply_knockback(damageRequest)

  -- Return an array of hits to apply to the entity
  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = health_lost,
    hitType = applyDamageRequest_update_hit_type(damageRequest),
    kind = "Normal",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = status.statusProperty("targetMaterialKind")
  }}
end

--- Returns `true` if the entity should be considered invulnerable
function applyDamageRequest_entity_is_invulnerable(_damageRequest)
  return self.hitInvulnerabilityTime > 0 or world.getProperty("nonCombat")
end

--- Applies the status effects of a damage request to the entity
function applyDamageRequest_apply_status_effects(damageRequest)
  status.addEphemeralEffects(
    damageRequest.statusEffects,
    damageRequest.sourceEntityId
  )
end

--- Reduces incoming damage if the entity has damage absorbtion active.
function applyDamageRequest_apply_damage_absorbtion(damage, damageRequest)
  -- NPCs don't apply damage absorbtion.
  return damage, damageRequest
end

--- Reduces incoming damage if the entity has a shield raised
function applyDamageRequest_apply_shield(damage, damageRequest)
  if
    damageRequest.hitType == "ShieldHit" and
    status.statPositive("shieldHealth") and
    status.resourcePositive("shieldStamina")
  then
    status.modifyResource("shieldStamina", -damage / status.stat("shieldHealth"))
    status.setResourcePercentage("shieldStaminaRegenBlock", 1.0)
    damage = 0
    damageRequest.statusEffects = {}
    damageRequest.damageSourceKind = "shield"
  end
  return damage, damageRequest
end

--- Reduces incoming damage if the entity has the appropriate resistances
function applyDamageRequest_apply_elemental_resistances(damage, damageRequest)
  -- NPC's don't apply elemental resistances
  return damage, "normalhit", damageRequest
end

--- Handles the application of invulnerability frames for this entity on hit
function applyDamageRequest_apply_invulnerability_frames(damage)
  local damageHealthPercentage = damage / status.resourceMax("health")
  if
    status.statusProperty("hitInvulnerabilityThreshold") ~= nil and
    damageHealthPercentage > status.statusProperty("hitInvulnerabilityThreshold")
  then
    self.hitInvulnerabilityTime =
      (status.statusProperty("hitInvulnerabilityTime") or 0)
  end
end

--- NPCs have special environmental damage rules
function applyDamageRequest_should_apply_environment_damage()
  return false
end

--- Determines the type and intensity of the hit damage flash
function applyDamageRequest_apply_damageFlashType(_flash_type, _damageRequest)
  -- NPCs don't do hit damage flash
end

--- Applies knockback momentum/velocity to the entity
function applyDamageRequest_apply_knockback(damageRequest)
  local momentum, knockback = applyDamageRequest_get_knockback_momentum(damageRequest)

  if status.resourcePositive("health") and knockback > 0 then
    -- NPCs reset their velocity on hit
    mcontroller.setVelocity({0,0})
    if knockback > status.stat("knockbackThreshold") then
      -- Apply knockback momentum
      if
        mcontroller.baseParameters().gravityEnabled and
        math.abs(momentum[1]) > 0
      then
        -- NPCs apply normal knockback when they're in gravity
        -- `knockback` is an absolute distance, so we need to re-assign the direction
        -- from `momentum` on the X axis.
        local dir = momentum[1] > 0 and 1 or -1
        mcontroller.addMomentum({dir * knockback / 1.41, knockback / 1.41})
      else
        -- NPCs apply exaggerated knockback when they're not in gravity
        mcontroller.addMomentum(momentum)
      end

      -- NPCs are stunned on knockback
      status.setResource(
        "stunned",
        math.max(
          status.resource("stunned"),
          status.stat("knockbackStunTime")
        )
      )
    end
  end
end

--- Determines knockback momentum
function applyDamageRequest_get_knockback_momentum(damageRequest)
  local knockbackFactor = (1 - status.stat("grit"))
  local momentum = vec2.mul(damageRequest.knockbackMomentum, knockbackFactor)

  return momentum, vec2.mag(momentum)
end

--- Updates the hitType of the damage request, usually setting it to kill
--- where appropriate
function applyDamageRequest_update_hit_type(damageRequest)
  if not status.resourcePositive("health") then
    return "kill"
  end
  return damageRequest.hitType
end


-- Update ---------------------------------------------------------------------

--- An engine supplied callback that fires on every update tick
function update(dt)
  update_apply_damage_flash(dt)
  update_apply_fall_damage(dt)
  update_apply_breathing(dt)
  update_apply_invulnerability_frames(dt)
  update_apply_energy_regen(dt)
  update_apply_shield_regen(dt)
  update_apply_world_limit(dt)
end

--- Applies a flashing directive when the entity is hit
function update_apply_damage_flash(dt)
  if self.damageFlashTime > 0 then
    local color = status.statusProperty("damageFlashColor") or "ff0000=0.85"
    if self.damageFlashType == "strong" then
      color = status.statusProperty("strongDamageFlashColor") or "ffffff=1.0" or color
    elseif self.damageFlashType == "weak" then
      color = status.statusProperty("weakDamageFlashColor") or "000000=0.0" or color
    end
    status.setPrimaryDirectives(string.format("fade=%s", color))
  else
    status.setPrimaryDirectives()
  end
  self.damageFlashTime = math.max(0, self.damageFlashTime - dt)
end

--- Applies fall damage to the entity
function update_apply_fall_damage(_dt)
  -- NPCs don't suffer from fall damage.
end

--- Applies breathing effects to the entity
function update_apply_breathing(_dt)
  -- NPCs don't breathe.
end

--- If the entity has invulnerability frames, this handles them.
function update_apply_invulnerability_frames(dt)
  if status.statusProperty("hitInvulnerability") then
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
end

--- Applies energy resource regeneration to the entity
function update_apply_energy_regen(dt)
  if status.resource("energy") == 0 then
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

--- Applies shield (item) resource regeneration to the entity
function update_apply_shield_regen(dt)
  if not status.resourcePositive("shieldStaminaRegenBlock") then
    status.modifyResourcePercentage(
      "shieldStamina",
      status.stat("shieldStaminaRegen") * dt
    )
  end
end

--- If the entity is at/below the bottom of the world, KILL THEM
function update_apply_world_limit(_dt)
  if mcontroller.atWorldLimit(true) then
    status.setResourcePercentage("health", 0)
  end
end

-- Other methods --------------------------------------------------------------

--- An engine supplied callback to handle changes to base resources
function notifyResourceConsumed(resourceName, amount)
  if resourceName == "energy" and amount > 0 then
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end
end

--- If the result of this function is not nil, draws overhead bars
function overheadBars()
  -- NPCs don't draw bars
  return nil
end
