require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/scripts/staticrandom.lua"
require "/items/buildscripts/abilities.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildweapon_plugins.config"

local function getConfigParameter(config, parameters, keyName, defaultValue)
  if parameters[keyName] ~= nil then
    return parameters[keyName]
  elseif config[keyName] ~= nil then
    return config[keyName]
  else
    return defaultValue
  end
end

function build(... --[[directory, config, parameters, level, seed]])
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  local directory, config, parameters, level, seed =
    Plugins.call_before_initialize_hooks("buildweapon", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  config, parameters = build_set_seed(config, parameters, seed)
  config, parameters = build_set_directory(config, parameters, directory)
  config, parameters = build_set_level(config, parameters, level)
  config, parameters = build_set_builderConfig(config, parameters)
  config, parameters = build_set_name(config, parameters)

  config, parameters = build_setup_abilities(config, parameters)
  config, parameters = build_setup_elemental_type(config, parameters)
  config, parameters = build_setup_damage_config(config, parameters)
  config, parameters = build_setup_shared_primary_attack_config(config,parameters)
  config, parameters = build_setup_melee_primary_attack_config(config,parameters)
  config, parameters = build_setup_ranged_primary_attack_config(config,parameters)
  config, parameters = build_setup_damage_level_multiplier(config,parameters)
  config, parameters = build_setup_palette_swaps(config,parameters)
  config, parameters = build_setup_animation_custom(config, parameters)
  config, parameters = build_setup_animation_parts(config, parameters)
  config, parameters = build_setup_gun_offsets(config, parameters)
  config, parameters = build_setup_elemental_fire_sounds(config,parameters)
  config, parameters = build_setup_inventory_icon(config, parameters)
  config, parameters = build_setup_tooltip_fields(config, parameters)
  config, parameters = build_set_price(config, parameters)

  -- PLUGIN LOADER ------------------------------------------------------------
  config, parameters = Plugins.call_after_initialize_hooks(
    "buildweapon",
    config,
    parameters
  )
  -- END PLUGIN LOADER --------------------------------------------------------

  return config, parameters
end

function scaleConfig(ratio, value)
  if type(value) == "table" then
    return util.lerp(ratio, value[1], value[2])
  else
    return value
  end
end

function build_set_seed(config, parameters, seed)
  -- initialize randomization
  if seed then
    parameters.seed = seed
  else
    seed = getConfigParameter(config, parameters, "seed", nil)
    if not seed then
      math.randomseed(util.seedTime())
      seed = math.random(1, 4294967295)
      parameters.seed = seed
    end
  end

  return config, parameters
end

function build_set_directory(config, parameters, directory)
  if directory then
    parameters.directory = directory
  end

  return config, parameters
end

function build_set_level(config, parameters, level)
  if
    level and
    not getConfigParameter(
      config,
      parameters,
      "fixedLevel",
      true
    )
  then
    parameters.level = level
  end

  return config, parameters
end

function build_set_builderConfig(config, parameters)
-- select the generation profile to use
  local builderConfig = {}
  if config.builderConfig then
    parameters.builderConfig = randomFromList(
      config.builderConfig,
      parameters.seed,
      "builderConfig"
    )
  end

  return config, parameters
end

function build_setup_abilities(config, parameters)
  setupAbility(
    config,
    parameters,
    "primary",
    parameters.builderConfig,
    parameters.seed
  )
  setupAbility(
    config,
    parameters,
    "alt",
    parameters.builderConfig,
    parameters.seed
  )

  return config, parameters
end

function build_setup_elemental_type(config, parameters)
  -- elemental type
  if
    not parameters.elementalType and
    type(parameters.builderConfig) == table and
    parameters.builderConfig.elementalType
  then
    parameters.elementalType = randomFromList(
      parameters.builderConfig.elementalType,
      parameters.seed,
      "elementalType"
    )
  end
  local elementalType = getConfigParameter(
    config,
    parameters,
    "elementalType",
    "physical"
  )
  replacePatternInData(config, nil, "<elementalType>", elementalType)

  -- elemental config
  if
    type(parameters.builderConfig) == table and
    parameters.builderConfig.elementalConfig
  then
    util.mergeTable(
      config, parameters.builderConfig.elementalConfig[elementalType]
    )
  end
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(
      config.altAbility,
      (config.altAbility.elementalConfig[elementalType] or {})
    )
  end

  -- elemental tag
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  replacePatternInData(
    config,
    nil,
    "<elementalName>",
    elementalType:gsub("^%l", string.upper)
  )

  return config, parameters
end

function build_set_name(config, parameters)
  -- name
  if
    not parameters.shortdescription and
    type(parameters.builderConfig) == table and
    parameters.builderConfig.nameGenerator
  then
    parameters.shortdescription =
      root.generateName(
        util.absolutePath(directory, parameters.builderConfig.nameGenerator),
        parameters.seed
      )
  end

  return config, parameters
end

function build_setup_damage_config(config, parameters)
  -- merge damage properties
  if
    type(parameters.builderConfig) == table and
    parameters.builderConfig.damageConfig
  then
    util.mergeTable(
      config.damageConfig or {},
      parameters.builderConfig.damageConfig
    )
  end

  return config, parameters
end

function build_setup_shared_primary_attack_config(config, parameters)
  -- preprocess shared primary attack config
  parameters.primaryAbility = parameters.primaryAbility or {}
  parameters.primaryAbility.fireTimeFactor = valueOrRandom(
    parameters.primaryAbility.fireTimeFactor,
    parameters.seed,
    "fireTimeFactor"
  )
  parameters.primaryAbility.baseDpsFactor = valueOrRandom(
    parameters.primaryAbility.baseDpsFactor,
    parameters.seed,
    "baseDpsFactor"
  )
  parameters.primaryAbility.energyUsageFactor = valueOrRandom(
    parameters.primaryAbility.energyUsageFactor,
    parameters.seed,
    "energyUsageFactor"
  )

  config.primaryAbility.fireTime = scaleConfig(
    parameters.primaryAbility.fireTimeFactor,
    config.primaryAbility.fireTime
  )
  config.primaryAbility.baseDps = scaleConfig(
    parameters.primaryAbility.baseDpsFactor,
    config.primaryAbility.baseDps
  )
  config.primaryAbility.energyUsage = scaleConfig(
    parameters.primaryAbility.energyUsageFactor,
    config.primaryAbility.energyUsage
  ) or 0

  return config, parameters
end

function build_setup_melee_primary_attack_config(config, parameters)
  -- preprocess melee primary attack config
  if
    config.primaryAbility.damageConfig and
    config.primaryAbility.damageConfig.knockbackRange
  then
    config.primaryAbility.damageConfig.knockback = scaleConfig(
      parameters.primaryAbility.fireTimeFactor,
      config.primaryAbility.damageConfig.knockbackRange
    )
  end

  return config, parameters
end

function build_setup_ranged_primary_attack_config(config, parameters)
  -- preprocess ranged primary attack config
  if config.primaryAbility.projectileParameters then
    config.primaryAbility.projectileType = randomFromList(
      config.primaryAbility.projectileType,
      parameters.seed,
      "projectileType"
    )
    config.primaryAbility.projectileCount = randomIntInRange(
      config.primaryAbility.projectileCount,
      parameters.seed,
      "projectileCount"
    ) or 1
    config.primaryAbility.fireType = randomFromList(
      config.primaryAbility.fireType,
      parameters.seed,
      "fireType"
    ) or "auto"
    config.primaryAbility.burstCount = randomIntInRange(
      config.primaryAbility.burstCount,
      parameters.seed,
      "burstCount"
    )
    config.primaryAbility.burstTime = randomInRange(
      config.primaryAbility.burstTime,
      parameters.seed,
      "burstTime"
    )
    if config.primaryAbility.projectileParameters.knockbackRange then
      config.primaryAbility.projectileParameters.knockback =
        scaleConfig(
          parameters.primaryAbility.fireTimeFactor,
          config.primaryAbility.projectileParameters.knockbackRange
        )
    end
  end

  return config, parameters
end

function build_setup_damage_level_multiplier(config, parameters)
  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction(
    "weaponDamageLevelMultiplier",
    getConfigParameter(
      config,
      parameters,
      "level",
      1
    )
  )

  return config, parameters
end

function build_setup_palette_swaps(config, parameters)
  -- build palette swap directives
  config.paletteSwaps = ""
  if
    type(parameters.builderConfig) == table and
    parameters.builderConfig.palette
  then
    local palette = root.assetJson(
      util.absolutePath(parameters.directory, parameters.builderConfig.palette)
    )
    local selectedSwaps = randomFromList(
      palette.swaps,
      parameters.seed,
      "paletteSwaps"
    )
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format(
        "%s?replace=%s=%s",
        config.paletteSwaps,
        k,
        v
      )
    end
  end

  return config, parameters
end

function build_setup_animation_custom(config, parameters)
  -- merge extra animationCustom
  if parameters.builderConfig.animationCustom then
    util.mergeTable(
      config.animationCustom or {},
      parameters.builderConfig.animationCustom
    )
  end

  return config, parameters
end

function build_setup_animation_parts(config, parameters)
  -- animation parts
  sb.logInfo(string.format("%s", util.tableToString(parameters.builderConfig)))
  if
    type(parameters.builderConfig) == 'table' and
    parameters.builderConfig.animationParts
  then
    sb.logInfo(string.format("Adding parts to `animationParts`"))
    config.animationParts = config.animationParts or {}
    if parameters.animationPartVariants == nil then
      parameters.animationPartVariants = {}
    end
    for k, v in pairs(parameters.builderConfig.animationParts) do
      if type(v) == "table" then
        if
          v.variants and (
            not parameters.animationPartVariants[k] or
            parameters.animationPartVariants[k] > v.variants
          )
        then
          parameters.animationPartVariants[k] = randomIntInRange(
            {1, v.variants},
            parameters.seed,
            "animationPart"..k
          )
        end
        config.animationParts[k] = util.absolutePath(
          parameters.directory,
          string.gsub(
            v.path,
            "<variant>",
            parameters.animationPartVariants[k] or ""
          )
        )
        sb.logInfo(string.format("Adding part '%s' to `animationParts`: %s", k, config.animationParts[k]))
        if v.paletteSwap then
          config.animationParts[k] =
            config.animationParts[k] .. config.paletteSwaps
        end
      else
        sb.logInfo(string.format("Adding part '%s' to `animationParts`: %s", k, v))
        config.animationParts[k] = v
      end
    end
  end
  sb.logInfo(string.format("Done adding parts to `animationParts`"))
  return config, parameters
end

function build_setup_gun_offsets(config, parameters)
  -- set gun part offsets
  local partImagePositions = {}
  if parameters.builderConfig.gunParts then
    construct(config, "animationCustom", "animatedParts", "parts")
    local imageOffset = {0,0}
    local gunPartOffset = {0,0}
    for _,part in ipairs(parameters.builderConfig.gunParts) do
      local imageSize = root.imageSize(config.animationParts[part])
      construct(config.animationCustom.animatedParts.parts, part, "properties")

      imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
      config.animationCustom.animatedParts.parts[part].properties.offset = {config.baseOffset[1] + imageOffset[1] / 8, config.baseOffset[2]}
      partImagePositions[part] = copy(imageOffset)
      imageOffset = vec2.add(imageOffset, {imageSize[1] / 2, 0})
    end
    config.muzzleOffset = vec2.add(config.baseOffset, vec2.add(config.muzzleOffset or {0,0}, vec2.div(imageOffset, 8)))
  end

  parameters.partImagePositions = partImagePositions

  return config, parameters
end

function build_setup_elemental_fire_sounds(config, parameters)
  -- elemental fire sounds
  if config.fireSounds then
    construct(config, "animationCustom", "sounds", "fire")
    local sound = randomFromList(config.fireSounds, parameters.seed, "fireSound")
    config.animationCustom.sounds.fire =
      type(sound) == "table" and sound or { sound }
  end

  return config, parameters
end

function build_setup_inventory_icon(config, parameters)
  -- build inventory icon
  if not config.inventoryIcon and config.animationParts then
    config.inventoryIcon = jarray()
    local parts = parameters.builderConfig.iconDrawables or {}
    for _,partName in pairs(parts) do
      assert(
        config.animationParts[partName] ~= nil,
        string.format(
          "Could not find an animationPart for '%s' in %s",
          partName,
          util.tableToString(config.animationParts)
        )
      )
      local drawable = {
        image = config.animationParts[partName] .. config.paletteSwaps,
        position = parameters.partImagePositions[partName]
      }
      table.insert(config.inventoryIcon, drawable)
    end
  end

  return config, parameters
end

function build_setup_tooltip_fields(config, parameters)
  -- populate tooltip fields
  config.tooltipFields = {}
  local fireTime = parameters.primaryAbility.fireTime or config.primaryAbility.fireTime or 1.0
  local baseDps = parameters.primaryAbility.baseDps or config.primaryAbility.baseDps or 0
  local energyUsage = parameters.primaryAbility.energyUsage or config.primaryAbility.energyUsage or 0
  config.tooltipFields.levelLabel = util.round(
    getConfigParameter(config, parameters, "level", 1),
    1
  )
  config.tooltipFields.dpsLabel = util.round(
    baseDps * config.damageLevelMultiplier,
    1
  )
  config.tooltipFields.speedLabel = util.round(1 / fireTime, 1)
  config.tooltipFields.damagePerShotLabel = util.round(
    baseDps * fireTime * config.damageLevelMultiplier,
    1
  )
  config.tooltipFields.energyPerShotLabel = util.round(
    energyUsage * fireTime,
    1
  )

  local elementalType = getConfigParameter(
    config,
    parameters,
    "elementalType",
    "physical"
  )
  if elementalType ~= "physical" then
    config.tooltipFields.damageKindImage =
      "/interface/elements/"..elementalType..".png"
  end

  if config.primaryAbility then
    config.tooltipFields.primaryAbilityTitleLabel = "Primary:"
    config.tooltipFields.primaryAbilityLabel =
      config.primaryAbility.name or "unknown"
  end
  if config.altAbility then
    config.tooltipFields.altAbilityTitleLabel = "Special:"
    config.tooltipFields.altAbilityLabel =
      config.altAbility.name or "unknown"
  end

  return config, parameters
end

function build_set_price(config, parameters)
  -- set price
  config.price = (config.price or 0) *
    root.evalFunction(
      "itemLevelPriceMultiplier",
      getConfigParameter(config, parameters, "level", 1)
    )

  return config, parameters
end
