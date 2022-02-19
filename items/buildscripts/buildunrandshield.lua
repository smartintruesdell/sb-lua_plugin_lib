require "/scripts/util.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildunrandshield_plugins.config"

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
    Plugins.call_before_initialize_hooks("buildunrandshield", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  config, parameters = build_set_seed(config, parameters, seed)
  config, parameters = build_set_directory(config, parameters, directory)
  config, parameters = build_set_level(config, parameters, level)

  config, parameters = build_setup_tooltip_fields(config, parameters)
  config, parameters = build_set_price(config, parameters)

  -- PLUGIN LOADER ------------------------------------------------------------
  config, parameters = Plugins.call_after_initialize_hooks(
    "buildunrandshield",
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
  config.tooltipFields.cooldownLabel =
    parameters.cooldownTime or config.cooldownTime

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
