require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildfood_plugins.config"

function build(... --[[directory, config, parameters, level, seed]])
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  local _directory, config, parameters, _level, _seed =
    Plugins.call_before_initialize_hooks("buildfood", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  if not parameters.timeToRot then
    local rottingMultiplier =
      parameters.rottingMultiplier or
      config.rottingMultiplier or
      1.0

    parameters.timeToRot =
      root.assetJson("/items/rotting.config:baseTimeToRot") * rottingMultiplier
  end

  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields.rotTimeLabel = getRotTimeDescription(parameters.timeToRot)

  -- PLUGIN LOADER ------------------------------------------------------------
  config, parameters = Plugins.call_after_initialize_hooks(
    "buildfood",
    config,
    parameters
  )
  -- END PLUGIN LOADER --------------------------------------------------------

  return config, parameters
end

function getRotTimeDescription(rotTime)
  local descList = root.assetJson("/items/rotting.config:rotTimeDescriptions")
  for i, desc in ipairs(descList) do
    if rotTime <= desc[1] then return desc[2] end
  end
  return descList[#descList]
end
