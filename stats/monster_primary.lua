require "/scripts/vec2.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/stats/monster_primary_plugins.config"

-- Module initialization ------------------------------------------------------

function init()

  self.damageFlashTime = 0

  message.setHandler("applyStatusEffect", applyStatusEffectCallback)

end

init = PluginLoader.add_plugin_loader("monster_primary", PLUGINS_PATH, init)

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
function applyDamageRequest_apply_health_lost(health_lost, damage)
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
  -- Early out if we're in a nonCombat world
  if world.getProperty("nonCombat") then return {} end

  -- Early out for status-only attacks
  if
    damageRequest.damageSourceKind == "applystatus" or
    damageRequest.damageType == "Status"
  then
    applyDamageRequest_apply_status_effects(damageRequest)
    return {}
  end

  -- Early out of Knockback-only attacks if we are immune to Knockback
  if damageRequest.damageType == "Knockback" and status.stat("grit") >= 1 then
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

  local health_lost = math.min(damage, status.resource("health"))
  if health_lost > 0 then
    applyDamageRequest_apply_damageFlashType(
      effectiveness,
      damageRequest
    )
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

--- Applies the status effects of a damage request to the entity
function applyDamageRequest_apply_status_effects(damageRequest)
  status.addEphemeralEffects(
    damageRequest.statusEffects,
    damageRequest.sourceEntityId
  )
end

--- Monsters have special environmental damage rules
function applyDamageRequest_should_apply_environment_damage()
  return false
end

--- Reduces incoming damage if the entity has damage absorbtion active.
function applyDamageRequest_apply_damage_absorbtion(damage, damageRequest)
  -- Monsters don't apply damage absorbtion.
  return damage, damageRequest
end

--- Reduces incoming damage if the entity has a shield raised
function applyDamageRequest_apply_shield(damage, damageRequest)
  if status.resourcePositive("shieldHealth") then
    local shieldAbsorb = math.min(damage, status.resource("shieldHealth"))
    status.modifyResource("shieldHealth", -shieldAbsorb)
    damage = damage - shieldAbsorb
  end
  return damage, damageRequest
end

--- Reduces incoming damage if the entity has the appropriate resistances
function applyDamageRequest_apply_elemental_resistances(damage, damageRequest)
  local effectiveness = "normalhit"
  local elementalStat = root.elementalResistance(damageRequest.damageSourceKind)
  local resistance = status.stat(elementalStat)
  damage = damage - (resistance * damage)
  if resistance ~= 0 and damage > 0 then
    effectiveness = resistance > 0 and "weakhit" or "stronghit"
  end

  return damage, effectiveness, damageRequest
end

--- Handles the application of invulnerability frames for this entity on hit
function applyDamageRequest_apply_invulnerability_frames(_damage)
  -- Monsters don't get invulnerability frames
end

--- Determines the type and intensity of the hit damage flash
function applyDamageRequest_apply_damageFlashType(flash_type, _damageRequest)
  if flash_type == "stronghit" then
    self.damageFlashTime = 0.07
    self.damageFlashType = "strong"
  elseif flash_type == "weakhit" then
    self.damageFlashTime = 0.07
    self.damageFlashType = "weak"
  else
    self.damageFlashTime = 0.07
    self.damageFlashType = "default"
  end
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

function update(dt)
  update_apply_damage_flash(dt)
  update_handle_fall_damage(dt)
  update_handle_breathing(dt)
  update_handle_invulnerability_frames(dt)
  update_handle_energy_regen(dt)
  update_handle_shield_regen(dt)
  update_handle_world_limit(dt)
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
function update_handle_fall_damage(_dt)
  -- Monsters don't suffer from fall damage.
end

--- Applies breathing effects to the entity
function update_handle_breathing(_dt)
  -- Monsters don't breathe.
end

--- If the entity has invulnerability frames, this handles them.
function update_handle_invulnerability_frames(_dt)
  -- Monsters don't get invulnerability frames
end

--- Applies energy resource regeneration to the entity
function update_handle_energy_regen(_dt)
  -- Monsters don't get energy regen
end

--- Applies shield (item) resource regeneration to the entity
function update_handle_shield_regen(_dt)
  -- Monsters don't get shield regen
end

--- If the entity is at/below the bottom of the world, KILL THEM
function update_handle_world_limit(_dt)
  if mcontroller.atWorldLimit(true) then
    status.setResourcePercentage("health", 0)
  end
end
