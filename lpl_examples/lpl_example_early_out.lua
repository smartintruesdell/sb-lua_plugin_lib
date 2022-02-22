--[[
  This example is a plugin for /items/active/weapons/weapon.lua which
  patches a specific sub-routine of that file to demonstrate the 'early out'
  feature.
]]
require "/scripts/lpl_plugin_util.lua"

-- `build_setup_elemental_type` is part of Weapon:init
build_setup_elemental_type = Plugins.add_before_hook(
  build_setup_elemental_type,
  function (config, parameters)
    -- "before" hooks receive the arguments that are passed to their host function

    -- Setting this flag stops execution of subsequent hooks of this type
    -- It is then automatically reset
    Plugins.early_out = true

    -- "before" hooks can modify the arguements, but should usually return them
    -- in the order received.
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

    -- Like with the "before" hooks, we want to return the same values
    -- we received, but we can modify them.
    return config, parameters
  end
)
build_setup_elemental_type = Plugins.add_after_hook(
  build_setup_elemental_type,
  function (config, parameters, _init_config, _init_parameters)
    -- This function should happen, but should stop the next from firing.
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
