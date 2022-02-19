require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/scripts/staticrandom.lua"
require "/items/buildscripts/abilities.lua"

require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/items/buildscripts/buildwhip_plugins.config"

local function getConfigParameter(config, parameters, keyName, defaultValue)
  if parameters[keyName] ~= nil then
    return parameters[keyName]
  elseif config[keyName] ~= nil then
    return config[keyName]
  else
    return defaultValue
  end
end

function build(directory, config, parameters, level, seed)
  config, parameters = build_set_seed(config, parameters, seed)
  config, parameters = build_set_directory(config, parameters, directory)
  config, parameters = build_set_level(config, parameters, level)
  config, parameters = build_set_builderConfig(config, parameters)
  config, parameters = build_set_name(config, parameters)
  config, parameters = build_set_price(config, parameters)

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

  return config, parameters
end

build = PluginLoader.add_plugin_loader("buildwhip", PLUGINS_PATH, build)

function build_set_seed(config, parameters, seed)
  -- initialize randomization
  -- buildbow does not apply a random seed
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
  -- buildbow has no builderConfig
  parameters.builderConfig = nil

  return config, parameters
end

function build_set_name(config, parameters)
  -- buildunrandweapon doesn't set a name

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
    type(parameters.builderConfig) == "table" and
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
    type(parameters.builderConfig) == "table" and
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

function build_setup_damage_config(config, parameters)
  -- buildbow doesn't setup damage config

  return config, parameters
end

function build_setup_shared_primary_attack_config(config, parameters)
  -- buildbow doesn't setup shared attack config

  return config, parameters
end

function build_setup_melee_primary_attack_config(config, parameters)
  -- buildbow doesn't setup melee attack config

  return config, parameters
end

function build_setup_ranged_primary_attack_config(config, parameters)
  -- buildbow doesn't setup ranged attack config

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
  -- buildbow doesn't setup palette swaps

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
  -- buildbow doesn't setup gun offsets

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
  config.tooltipFields = {}
  config.tooltipFields.subtitle = parameters.category
  config.tooltipFields.speedLabel = util.round(1 / config.primaryAbility.fireTime, 1)
  config.tooltipFields.damagePerShotLabel = util.round(
    (config.primaryAbility.crackDps + config.primaryAbility.chainDps) *
      config.primaryAbility.fireTime * config.damageLevelMultiplier,
    1
  )
  if config.elementalType and config.elementalType ~= "physical" then
    config.tooltipFields.damageKindImage =
      "/interface/elements/"..config.elementalType..".png"
  end

  if config.altAbility then
    config.tooltipFields.altAbilityTitleLabel = "Special:"
    config.tooltipFields.altAbilityLabel = config.altAbility.name or "unknown"
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
