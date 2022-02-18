require "/scripts/util.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/items/buildscripts/buildsapling_plugins.config"

function build(... --[[directory, config, parameters, level, seed]])
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  local _directory, config, parameters, _level, _seed =
    Plugins.call_before_initialize_hooks("buildsapling", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  if not parameters.stemName then
    -- a pine tree isn't PERFECTLY generic but it's close enough
    parameters.stemName = "pineytree"
    parameters.foliageName = parameters.foliageName or "pinefoliage"
  end

  config.inventoryIcon = jarray()

  table.insert(
    config.inventoryIcon,
    {
      image = string.format(
        "%s?hueshift=%s",
        util.absolutePath(
          root.treeStemDirectory(parameters.stemName),
          "saplingicon.png"
        ),
        parameters.stemHueShift or 0
      )
    }
  )

  if parameters.foliageName then
    table.insert(
      config.inventoryIcon,
      {
        image = string.format(
          "%s?hueshift=%s",
          util.absolutePath(
            root.treeFoliageDirectory(parameters.foliageName),
            "saplingicon.png"
          ),
          parameters.foliageHueShift or 0
        )
      }
    )
  end

  -- PLUGIN LOADER ------------------------------------------------------------
  config, parameters = Plugins.call_after_initialize_hooks(
    "buildsapling",
    config,
    parameters
  )
  -- END PLUGIN LOADER --------------------------------------------------------

  return config, parameters
end
