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

function build(directory, config, parameters, level, seed)
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("buildunrandweapon")
  -- END PLUGIN LOADER --------------------------------------------------------

  config, parameters = build_set_level(config, parameters, level, seed)
  config, parameters = build_setup_abilities(config, parameters, seed)
  config, parameters = build_setup_elemental_type(config, parameters, seed)
  config, parameters = build_setup_damage_level_multiplier(
    config,
    parameters,
    seed
  )
  config, parameters = build_setup_palette_swaps(
    directory,
    config,
    parameters,
    seed
  )
  config, parameters = build_setup_gun_offsets(config, parameters, seed)
  config, parameters = build_setup_tooltip_fields(config, parameters, seed)
  config, parameters = build_set_price(config, parameters, seed)

  -- PLUGIN LOADER ------------------------------------------------------------
  config, parameters = Plugins.call_after_initialize_hooks(
    "buildunrandweapon",
    config,
    parameters
  )
  -- END PLUGIN LOADER --------------------------------------------------------

  return config, parameters
end

function build_set_level(config, parameters, level, _seed)
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

function build_setup_abilities(config, parameters, level, _seed)
  setupAbility(config, parameters, "primary")
  setupAbility(config, parameters, "alt")

  return config, parameters
end

function build_setup_elemental_type(config, parameters, _seed)
  -- elemental type and config (for alt ability)
  local elementalType = getConfigParameter(
    config,
    parameters,
    "elementalType",
    "physical"
  )
  replacePatternInData(config, nil, "<elementalType>", elementalType)

  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(
      config.altAbility,
      config.altAbility.elementalConfig[elementalType]
    )
  end

  return config, parameters
end

function build_setup_damage_level_multiplier(config, parameters, _seed)
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

function build_setup_palette_swaps(directory, config, parameters, _seed)
  -- palette swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(util.absolutePath(directory, config.palette))
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

function build_setup_gun_offsets(config, parameters, seed)
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

function build_setup_tooltip_fields(config, parameters, _seed)
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

function build_set_price(config, parameters, _seed)
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
