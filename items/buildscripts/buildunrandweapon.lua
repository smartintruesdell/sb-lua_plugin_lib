require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildunrandweapon_plugins.config"

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
    Plugins.call_before_initialize_hooks("buildunrandweapon", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  config, parameters = build_set_seed(config, parameters, seed)
  config, parameters = build_set_directory(config, parameters, directory)
  config, parameters = build_set_level(config, parameters, level)
  config, parameters = build_set_builderConfig(config,parameters)
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
    "buildunrandweapon",
    config,
    parameters
  )
  -- END PLUGIN LOADER --------------------------------------------------------

  return config, parameters
end

function build_set_seed(config, parameters, seed)
  -- initialize randomization
  -- unrandweapon does not apply a random seed
  if seed then
    parameters.seed = seed
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
  -- unrandweapon has no builderConfig
  parameters.builderConfig = nil

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
      config.altAbility.elementalConfig[elementalType]
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
  -- buildunrandweapon doesn't set a name

  return config, parameters
end

function build_setup_damage_config(config, parameters)
  -- buildunrandweapon doesn't setup damage config

  return config, parameters
end

function build_setup_shared_primary_attack_config(config, parameters)
  -- buildunrandweapon doesn't setup shared attack config

  return config, parameters
end

function build_setup_melee_primary_attack_config(config, parameters)
  -- buildunrandweapon doesn't setup melee attack config

  return config, parameters
end

function build_setup_ranged_primary_attack_config(config, parameters)
  -- buildunrandweapon doesn't setup ranged attack config

  return config, parameters
end

function build_setup_damage_level_multiplier(config, parameters)
  -- calculate damage level multiplier
  config.damageLevelMultiplier =
    root.evalFunction(
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
  -- palette swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(
      util.absolutePath(parameters.directory, config.palette)
    )
    local colorIndex = getConfigParameter(
      config,
      parameters,
      "colorIndex",
      1
    )
    local selectedSwaps = palette.swaps[colorIndex]
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format(
        "%s?replace=%s=%s",
        config.paletteSwaps,
        k,
        v
      )
    end
  end
  if type(config.inventoryIcon) == "string" then
    config.inventoryIcon = config.inventoryIcon .. config.paletteSwaps
  else
    for _, drawable in ipairs(config.inventoryIcon) do
      if drawable.image then
        drawable.image = drawable.image .. config.paletteSwaps
      end
    end
  end

  return config, parameters
end

function build_setup_animation_custom(config, parameters)
  -- buildunrandweapon doesn't setup animation custom

  return config, parameters
end

function build_setup_animation_parts(config, parameters)
  -- buildunrandweapon doesn't setup animation parts

  return config, parameters
end

function build_setup_gun_offsets(config, parameters)
  if config.baseOffset then
    construct(
      config,
      "animationCustom",
      "animatedParts",
      "parts",
      "middle",
      "properties"
    )
    config.animationCustom.animatedParts.parts.middle.properties.offset =
      config.baseOffset

    if config.muzzleOffset then
      config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset)
    end
  end

  return config, parameters
end

function build_setup_elemental_fire_sounds(config, parameters)
  -- buildunrandweapon doesn't setup elemental fire sounds

  return config, parameters
end

function build_setup_inventory_icon(config, parameters)
  -- buildunrandweapon doesn't setup an inventory icon

  return config, parameters
end

function build_setup_tooltip_fields(config, parameters)
  -- populate tooltip fields
  if config.tooltipKind ~= "base" then
    config.tooltipFields = {}
    config.tooltipFields.levelLabel =
      util.round(getConfigParameter(config, parameters, "level", 1), 1)
    config.tooltipFields.dpsLabel = util.round(
      (config.primaryAbility.baseDps or 0) * config.damageLevelMultiplier,
      1
    )
    config.tooltipFields.speedLabel = util.round(
      1 / (config.primaryAbility.fireTime or 1.0),
      1
    )
    config.tooltipFields.damagePerShotLabel =
      util.round(
        (config.primaryAbility.baseDps or 0) *
        (config.primaryAbility.fireTime or 1.0) *
        config.damageLevelMultiplier,
        1
      )
    config.tooltipFields.energyPerShotLabel =
      util.round(
        (config.primaryAbility.energyUsage or 0) *
        (config.primaryAbility.fireTime or 1.0),
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
  end

  return config, parameters
end

function build_set_price(config, parameters)
  -- set price
  -- TODO: should this be handled elsewhere?
  config.price =
    (config.price or 0) *
    root.evalFunction(
      "itemLevelPriceMultiplier",
      getConfigParameter(
        config,
        parameters,
        "level",
        1
      )
    )

  return config, parameters
end
