require("/scripts/vec2.lua")
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/vehicles/sportscar/sportscar_plugins.config"

function init()
  self.levelApproachFactor = config.getParameter("levelApproachFactor")
  self.angleApproachFactor = config.getParameter("angleApproachFactor")
  self.maxGroundSearchDistance = config.getParameter("maxGroundSearchDistance")
  self.maxAngle = config.getParameter("maxAngle") * math.pi / 180
  self.hoverTargetDistance = config.getParameter("hoverTargetDistance")
  self.hoverVelocityFactor = config.getParameter("hoverVelocityFactor")
  self.hoverControlForce = config.getParameter("hoverControlForce")
  self.targetHorizontalVelocity = config.getParameter("targetHorizontalVelocity")
  self.horizontalControlForce = config.getParameter("horizontalControlForce")
  self.zeroGTargetVelocity = config.getParameter("zeroGTargetVelocity")
  self.zeroGSpinRate = config.getParameter("zeroGSpinRate")
  self.spinFriction = config.getParameter("spinFriction")
  self.backSpringPositions = config.getParameter("backSpringPositions")
  self.frontSpringPositions = config.getParameter("frontSpringPositions")
  self.bodySpringPositions = config.getParameter("bodySpringPositions")
  self.movementSettings = config.getParameter("movementSettings")
  self.occupiedMovementSettings = config.getParameter("occupiedMovementSettings")
  self.zeroGMovementSettings = config.getParameter("zeroGMovementSettings")
  self.protection = config.getParameter("protection")
  self.maxHealth = config.getParameter("maxHealth")

  self.smokeThreshold =  config.getParameter("smokeParticleHealthThreshold")
  self.fireThreshold =  config.getParameter("fireParticleHealthThreshold")
  self.maxSmokeRate = config.getParameter("smokeRateAtZeroHealth")
  self.maxFireRate = config.getParameter("fireRateAtZeroHealth")

  self.onFireThreshold =  config.getParameter("onFireHealthThreshold")
  self.damagePerSecondWhenOnFire =  config.getParameter("damagePerSecondWhenOnFire")

  self.engineDamageSoundThreshold =  config.getParameter("engineDamageSoundThreshold")
  self.intermittentDamageSoundThreshold = config.getParameter("intermittentDamageSoundThreshold")

  --this is a range
  self.maxDamageSoundInterval = config.getParameter("maxDamageSoundInterval")
  self.minDamageSoundInterval = config.getParameter("minDamageSoundInterval")

  self.minDamageCollisionAccel = config.getParameter("minDamageCollisionAccel")
  self.minNotificationCollisionAccel = config.getParameter("minNotificationCollisionAccel")
  self.terrainCollisionDamage = config.getParameter("terrainCollisionDamage")
  self.materialKind = config.getParameter("materialKind")
  self.terrainCollisionDamageSourceKind = config.getParameter("terrainCollisionDamageSourceKind")
  self.accelerationTrackingCount = config.getParameter("accelerationTrackingCount")

  self.damageStateNames = config.getParameter("damageStateNames")

  self.engineIdlePitch = config.getParameter("engineIdlePitch")
  self.engineRevPitch = config.getParameter("engineRevPitch")
  self.engineIdleVolume = config.getParameter("engineIdleVolume")
  self.engineRevVolume = config.getParameter("engineRevVolume")

  self.loopPlaying = nil;
  self.enginePitch = self.engineRevPitch;
  self.engineVolume = self.engineIdleVolume;

  self.driver = nil;
  self.facingDirection = 1
  self.angle = 0
  self.engineRevTimer = 0.0
  self.revEngine = false
  self.damageSoundTimer = 0.0
  self.spin = 0

  self.lastPosition = mcontroller.position()
  self.collisionDamageTrackingVelocities = {}
  self.collisionNotificationTrackingVelocities = {}
  self.selfDamageNotifications = {}

  --this comes in from the controller.
  self.ownerKey = config.getParameter("ownerKey")
  vehicle.setPersistent(self.ownerKey)

  --assume maxhealth
  if (storage.health) then
    animator.setAnimationState("movement", "idle")
  else
    local startHealthFactor = config.getParameter("startHealthFactor")

    if (startHealthFactor == nil) then
        storage.health = self.maxHealth
    else
       storage.health = math.min(startHealthFactor * self.maxHealth, self.maxHealth)
    end
    animator.setAnimationState("movement", "warpInPart1")
  end

  --setup the store functionality
  message.setHandler("store",
      function(_, _, ownerKey)
        if (self.ownerKey and self.ownerKey == ownerKey and self.driver == nil and animator.animationState("movement") == "idle") then
          animator.setAnimationState("movement", "warpOutPart1")
          animator.playSound("returnvehicle")
          return {storable = true, healthFactor = storage.health / self.maxHealth}
        else
          return {storable = false, healthFactor = storage.health / self.maxHealth}
        end
      end)

  updateVisualEffects(storage.health, 0, false)
end
init = PluginLoader.add_plugin_loader("sportscar", PLUGINS_PATH, init)

function update()
  if mcontroller.atWorldLimit() then
    vehicle.destroy()
    return
  end

  if (animator.animationState("movement") == "invisible") then
    vehicle.destroy()
  elseif (animator.animationState("movement") == "warpInPart1" or animator.animationState("movement") == "warpOutPart2") then
    mcontroller.setPosition(self.lastPosition)
    mcontroller.setVelocity({0, 0})
  else
    local driverThisFrame = vehicle.entityLoungingIn("drivingSeat")

    if (driverThisFrame ~= nil) then
      vehicle.setDamageTeam(world.entityDamageTeam(driverThisFrame))
    else
      vehicle.setDamageTeam({type = "passive"})
    end

    local healthFactor = storage.health / self.maxHealth

    if mcontroller.zeroG() then
      moveZeroG()
    else
      move()
    end
    animate()
    updateDamage()
    updateDriveEffects(healthFactor, driverThisFrame)

    self.driver = driverThisFrame
  end
end

function updateDriveEffects(healthFactor, driverThisFrame)
  local startSoundName = "engineStart"
  local loopSoundName = "engineLoop"

  if (healthFactor < self.engineDamageSoundThreshold) then
    startSoundName = "engineStartDamaged"
    loopSoundName = "engineLoopDamaged"
  end

  --do we have a driver ?
  if (driverThisFrame ~= nil) then
    --has someone got in ?
    if (self.driver == nil) then
      animator.playSound(startSoundName)
    end

    --is the sound we want different to the sound we have ?
    if (loopSoundName ~= self.loopPlaying) then
      if (self.loopPlaying ~= nil) then
        animator.playSound("damageIntermittent")
        animator.stopAllSounds(self.loopPlaying, 0.5)
      end
      animator.playSound(loopSoundName, -1)
      self.loopPlaying = loopSoundName
    end
  else
    --no driver, stop the engine
    if (self.loopPlaying ~= nil) then
      animator.stopAllSounds(self.loopPlaying, 0.5)
      self.loopPlaying = nil
    end
  end

  -- is the engine sound playing ?
  if (self.loopPlaying ~= nil) then
    -- a brief burst of power
    if (self.revEngine == true)  then
      -- instantly set them to full power.
      self.engineRevTimer = 0.5
      animator.setSoundPitch(self.loopPlaying, self.engineRevPitch, self.engineRevTimer)
      animator.setSoundVolume(self.loopPlaying, self.engineRevVolume, self.engineRevTimer)

      self.revEngine = false
    else
      if (self.engineRevTimer > 0.0)  then
        self.engineRevTimer = self.engineRevTimer - script.updateDt()
      else
        --settling to the normal engine pitch and volume
        animator.setSoundPitch(self.loopPlaying, self.enginePitch, 1.5)
        animator.setSoundVolume(self.loopPlaying, self.engineVolume, 1.5)
      end
    end
  end

  --if burning, takew dammage intermittantly.
  if (self.loopPlaying ~= nil or (self.onFireThreshold and healthFactor < self.onFireThreshold)) then
    --time to go snap crackle or pop ?
    if (healthFactor < self.intermittentDamageSoundThreshold) then
      self.damageSoundTimer = self.damageSoundTimer - script.updateDt()

      if (self.damageSoundTimer <= 0) then
        animator.playSound("damageIntermittent")

        --a random time that changes depending on how damaged the vehicle is.
        local randomMax = (healthFactor * self.maxDamageSoundInterval) + ((1.0 - healthFactor) * self.minDamageSoundInterval)

        animator.burstParticleEmitter("damageIntermittent")

        self.damageSoundTimer = math.random() * randomMax;
      end
    end
  end
end

function updateVisualEffects(currentHealth, damage)
  local maxDamageState = #self.damageStateNames
  local prevHealthFactor = currentHealth / self.maxHealth

  --work out the factor after damage occurs.
  local newHealthFactor = (currentHealth - damage) / self.maxHealth

  --work out what damage state we are in before damage occurs
  local previousDamageStateIndex = maxDamageState
  if prevHealthFactor > 0 then
    previousDamageStateIndex = (maxDamageState - math.ceil(prevHealthFactor * maxDamageState)) + 1
  end

  --now the damage state after damage occurs
  local damageStateIndex = maxDamageState
  if newHealthFactor > 0 then
    damageStateIndex = (maxDamageState - math.ceil(newHealthFactor * maxDamageState)) + 1
  end

  --if we've changed damage state make some danaged effects.
  if (damageStateIndex > previousDamageStateIndex) then
    animator.burstParticleEmitter("damageShards")
    animator.playSound("changeDamageState")
  end

  animator.setGlobalTag("damageState", self.damageStateNames[damageStateIndex])

  --smoke particles and fire
  if newHealthFactor < 1.0 then
    if (self.smokeThreshold > 0 and newHealthFactor < self.smokeThreshold) then
      local smokeFactor = 1.0 - (newHealthFactor / self.smokeThreshold)
      animator.setParticleEmitterActive("smoke", true)
      animator.setParticleEmitterEmissionRate("smoke", smokeFactor * self.maxSmokeRate)
    end

    if (self.fireThreshold > 0 and newHealthFactor < self.fireThreshold) then
      local fireFactor = 1.0 - (newHealthFactor / self.fireThreshold)
      animator.setParticleEmitterActive("fire", true)
      animator.setParticleEmitterEmissionRate("fire", fireFactor * self.maxFireRate)
    end
  else
    animator.setParticleEmitterActive("smoke", false)
    animator.setParticleEmitterActive("fire", false)
  end
end

function applyDamage(damageRequest)
  local damage = 0
  if damageRequest.damageType == "Damage" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, self.protection)
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  else
    return {}
  end

  updateVisualEffects(storage.health, damage)

  local healthLost = math.min(damage, storage.health)
  storage.health = storage.health - healthLost

  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = healthLost,
    hitType = "Hit",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = self.materialKind,
    killed = storage.health <= 0
  }}
end

function selfDamageNotifications()
  local sdn = self.selfDamageNotifications
  self.selfDamageNotifications = {}
  return sdn
end

function moveZeroG()
  local dt = script.updateDt()
  if self.spin > 0 then
    self.spin = math.max(0, self.spin - self.spinFriction * dt)
  else
    self.spin = math.min(0, self.spin + self.spinFriction * dt)
  end

  self.angle = self.angle + self.spin * dt

  mcontroller.resetParameters(self.movementSettings)
  mcontroller.applyParameters(self.zeroGMovementSettings)

  local controlDirection = 0
  if vehicle.controlHeld("drivingSeat", "right") then
    controlDirection = controlDirection + 1
  end
  if vehicle.controlHeld("drivingSeat", "left") then
    controlDirection = controlDirection - 1
  end

  if controlDirection ~= 0 then
    self.spin = self.spin - self.zeroGSpinRate * controlDirection * dt
    self.facingDirection = controlDirection

    local boostVec = vec2.mul(vec2.withAngle(self.angle, self.zeroGTargetVelocity), controlDirection)
    mcontroller.approachVelocity(boostVec, self.horizontalControlForce)

    self.enginePitch = self.engineRevPitch;
    self.engineVolume = self.engineRevVolume;
  end
end

function move()
  self.spin = 0

  local groundDistance = minimumSpringDistance(self.bodySpringPositions)

  --assume idle pitch
  self.enginePitch = self.engineIdlePitch;
  self.engineVolume = self.engineIdleVolume;

  mcontroller.resetParameters(self.movementSettings)
  if self.driver then
    mcontroller.applyParameters(self.occupiedMovementSettings)
  end
  if groundDistance <= self.hoverTargetDistance then
    mcontroller.approachYVelocity((self.hoverTargetDistance - groundDistance) * self.hoverVelocityFactor, self.hoverControlForce)
  end

  if vehicle.controlHeld("drivingSeat", "left") then
    mcontroller.approachXVelocity(-self.targetHorizontalVelocity, self.horizontalControlForce)
    self.facingDirection = -1

    self.enginePitch = self.engineRevPitch;
    self.engineVolume = self.engineRevVolume;
  end

  if vehicle.controlHeld("drivingSeat", "right") then
    mcontroller.approachXVelocity(self.targetHorizontalVelocity, self.horizontalControlForce)
    self.facingDirection = 1

    self.enginePitch = self.engineRevPitch;
    self.engineVolume = self.engineRevVolume;
  end

  if vehicle.controlHeld("drivingSeat", "up") then
    local targetAngle = (self.facingDirection < 0) and -self.maxAngle or self.maxAngle
    self.angle = self.angle + (targetAngle - self.angle) * self.angleApproachFactor

    self.enginePitch = self.engineRevPitch;
    self.engineVolume = self.engineRevVolume;
  elseif vehicle.controlHeld("drivingSeat", "down") then
    local targetAngle = (self.facingDirection < 0) and self.maxAngle or -self.maxAngle
    self.angle = self.angle + (targetAngle - self.angle) * self.angleApproachFactor
  else
    local frontSpringDistance = minimumSpringDistance(self.frontSpringPositions)
    local backSpringDistance = minimumSpringDistance(self.backSpringPositions)
    if frontSpringDistance == self.maxGroundSearchDistance and backSpringDistance == self.maxGroundSearchDistance then
      self.angle = self.angle - self.angle * self.angleApproachFactor
    else
      self.angle = self.angle + math.atan((backSpringDistance - frontSpringDistance) * self.levelApproachFactor)
      self.angle = math.min(math.max(self.angle, -self.maxAngle), self.maxAngle)
    end
  end

  mcontroller.setRotation(self.angle)
end

function animate()
  animator.resetTransformationGroup("flip")
  if self.facingDirection < 0 then
    animator.scaleTransformationGroup("flip", {-1, 1})
  end

  animator.resetTransformationGroup("rotation")
  animator.rotateTransformationGroup("rotation", self.angle)
end

function updateDamage()
  if storage.health <= 0 then
    animator.burstParticleEmitter("damageShards")
    animator.burstParticleEmitter("wreckage")
    animator.playSound("explode")

    local projectileConfig = {
      damageTeam = { type = "indiscriminate" },
      power = config.getParameter("explosionDamage"),
      onlyHitTerrain = false,
      timeToLive = 0,
      actionOnReap = {
        {
          action = "config",
          file =  config.getParameter("explosionConfig")
        }
      }
    }
    world.spawnProjectile("invisibleprojectile", mcontroller.position(), 0, {0, 0}, false, projectileConfig)

    vehicle.destroy()
  end

  local newPosition = mcontroller.position()
  local newVelocity = vec2.div(vec2.sub(newPosition, self.lastPosition), script.updateDt())
  self.lastPosition = newPosition

  if mcontroller.isColliding() then
    function findMaxAccel(trackedVelocities)
      local maxAccel = 0
      for _, v in ipairs(trackedVelocities) do
        local accel = vec2.mag(vec2.sub(newVelocity, v))
        if accel > maxAccel then
          maxAccel = accel
        end
      end
      return maxAccel
    end

    if findMaxAccel(self.collisionDamageTrackingVelocities) >= self.minDamageCollisionAccel then
      animator.playSound("collisionDamage")

      updateVisualEffects(storage.health, self.terrainCollisionDamage)

      storage.health = storage.health - self.terrainCollisionDamage
      self.collisionDamageTrackingVelocities = {}
      self.collisionNotificationTrackingVelocities = {}

      table.insert(self.selfDamageNotifications, {
        sourceEntityId = entity.id(),
        targetEntityId = entity.id(),
        position = mcontroller.position(),
        damageDealt = self.terrainCollisionDamage,
        healthLost = self.terrainCollisionDamage,
        hitType = "Hit",
        damageSourceKind = self.terrainCollisionDamageSourceKind,
        targetMaterialKind = self.materialKind,
        killed = storage.health <= 0
      })
    end

    if findMaxAccel(self.collisionNotificationTrackingVelocities) >= self.minNotificationCollisionAccel then
      animator.playSound("collisionNotification")
      self.collisionNotificationTrackingVelocities = {}
    end
  end

  function appendTrackingVelocity(trackedVelocities, newVelocity)
    table.insert(trackedVelocities, newVelocity)
    while #trackedVelocities > self.accelerationTrackingCount do
      table.remove(trackedVelocities, 1)
    end
  end

  appendTrackingVelocity(self.collisionDamageTrackingVelocities, newVelocity)
  appendTrackingVelocity(self.collisionNotificationTrackingVelocities, newVelocity)
end

function minimumSpringDistance(points)
  local min = nil
  for _, point in ipairs(points) do
    point = vec2.rotate(point, self.angle)
    point = vec2.add(point, mcontroller.position())
    local d = distanceToGround(point)
    if min == nil or d < min then
      min = d
    end
  end
  return min
end

function distanceToGround(point)
  local endPoint = vec2.add(point, {0, -self.maxGroundSearchDistance})

  world.debugLine(point, endPoint, {255, 255, 0, 255})
  local intPoint = world.lineCollision(point, endPoint)

  if intPoint then
    world.debugPoint(intPoint, {255, 255, 0, 255})
    return point[2] - intPoint[2]
  else
    return self.maxGroundSearchDistance
  end
end
