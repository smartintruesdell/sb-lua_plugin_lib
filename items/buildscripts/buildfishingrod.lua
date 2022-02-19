require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/items/buildscripts/buildfishingrod_plugins.config"

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

  config, parameters = build_setup_tooltip_fields(config, parameters)

  return config, parameters
end

build = PluginLoader.add_plugin_loader("buildfishingrod", PLUGINS_PATH, build)

function build_set_seed(config, parameters, seed)
  -- initialize randomization
  -- buildfishingrod does not apply a random seed
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
  config.tooltipFields = config.tooltipFields or {}

  config.tooltipFields.reelNameLabel = parameters.reelName or config.reelName
  config.tooltipFields.reelIconImage = parameters.reelIcon or config.reelIcon

  config.tooltipFields.lureNameLabel = parameters.lureName or config.lureName
  config.tooltipFields.lureIconImage = parameters.lureIcon or config.lureIcon

  return config, parameters
end

function getRotTimeDescription(rotTime)
  local descList = root.assetJson("/items/rotting.config:rotTimeDescriptions")
  for i, desc in ipairs(descList) do
    if rotTime <= desc[1] then return desc[2] end
  end
  return descList[#descList]
end
