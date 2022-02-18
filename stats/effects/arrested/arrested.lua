require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "/stats/effects/arrested/arrested_plugins.config"

-- Module initialization ------------------------------------------------------

function init()
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  Plugins.call_before_initialize_hooks("arrested")
  -- END PLUGIN LOADER --------------------------------------------------------

  apply_effect()

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("arrested")
  -- END PLUGIN LOADER --------------------------------------------------------
end


function apply_effect()
  effect.addStatModifierGroup({
    {stat = "arrested", amount = 1},
    {stat = "invulnerable", amount = 1},
    {stat = "fireStatusImmunity", amount = 1},
    {stat = "iceStatusImmunity", amount = 1},
    {stat = "electricStatusImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
    {stat = "powerMultiplier", effectiveMultiplier = 0},
    {stat = "specialStatusImmunity", amount = 1}
  })
end

function update(dt) end

function onExpire() end
