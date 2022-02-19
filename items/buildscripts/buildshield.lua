require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildshield_plugins.config"

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
    Plugins.call_before_initialize_hooks("buildshield", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  config, parameters = build_set_seed(config, parameters, seed)
  config, parameters = build_set_directory(config, parameters, directory)
  config, parameters = build_set_level(config, parameters, level)
  config, parameters = build_set_builderConfig(config, parameters)
  config, parameters = build_set_name(config, parameters)

  config, parameters = build_setup_palette_swaps(config,parameters)
  config, parameters = build_setup_animation_custom(config, parameters)
  config, parameters = build_setup_animation_parts(config, parameters)

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
  if parameters.builderConfig.animationParts then
    if parameters.animationParts == nil then parameters.animationParts = {} end
    for k, v in pairs(parameters.builderConfig.animationParts) do
      if parameters.animationParts[k] == nil then
        if type(v) == "table" then
          parameters.animationParts[k] = util.absolutePath(
            parameters.directory,
            string.gsub(
              v.path,
              "<variant>",
              randomIntInRange(
                {1, v.variants},
                parameters.seed,
                "animationPart"..k
              )
            )
          )
        else
          parameters.animationParts[k] = v
        end

        -- use near idle frame of shield for inventory icon for now
        if k == "shield" and not parameters.inventoryIcon then
          parameters.inventoryIcon = parameters.animationParts[k]..":nearidle"
        end
      end
    end
  end

  return config, parameters
end

function build_setup_tooltip_fields(config, parameters)
  -- tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.healthLabel = util.round(
    getConfigParameter(config, parameters, "baseShieldHealth", 0) *
    root.evalFunction(
      "shieldLevelMultiplier",
      getConfigParameter(config, parameters, "level", 1)
    ),
    0
  )
  config.tooltipFields.cooldownLabel = getConfigParameter(
    config,
    parameters,
    "cooldownTime"
  )

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
