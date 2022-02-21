--[[ Test Plugin, treat this like data: It's very mutable ]]
require "/scripts/util.lua"
require "/scripts/lpl_plugin_util.lua"

Plugins.debug = true

build_setup_elemental_type = Plugins.add_before_hook(
  build_setup_elemental_type,
  function (config, parameters)
    -- Setting this flag stops execution of subsequent hooks of this type
    -- It is then automatically reset
    Plugins.early_out = true
    return config, parameters
  end
)
build_setup_elemental_type = Plugins.add_before_hook(
  build_setup_elemental_type,
  function (config, parameters)
    -- This function should never happen, because of the early out.
    sb.logInfo("SHOULDN'T HAPPEN")
    return config, parameters
  end
)

build_setup_elemental_type = Plugins.add_after_hook(
  build_setup_elemental_type,
  function (config, parameters, _init_config, _init_parameters)
    -- We receive the results of the function along with the arguments that were
    -- returned by the before hooks.
    return config, parameters
  end
)
build_setup_elemental_type = Plugins.add_after_hook(
  build_setup_elemental_type,
  function (config, parameters, _init_config, _init_parameters)
    -- This function should never happen, because of the early out.
    sb.logInfo("SHOULD HAPPEN")
    Plugins.early_out = true
    return config, parameters
  end
)
build_setup_elemental_type = Plugins.add_after_hook(
  build_setup_elemental_type,
  function (config, parameters, _init_config, _init_parameters)
    -- This function should never happen, because of the early out.
    sb.logInfo("SHOULDN'T HAPPEN")
    return config, parameters
  end
)
