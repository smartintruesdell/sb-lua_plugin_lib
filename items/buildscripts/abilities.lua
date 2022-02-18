require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

require "/scripts/lpl_load_plugins.lua"
require "/scripts/lpl_plugin_util.lua"
local PLUGINS_PATH = "items/buildscripts/abilities_plugins.config"

local abilityTablePath = "/items/buildscripts/weaponabilities.config"
local abilities = nil

function getAbilitySourceFromType(abilityType)
  if not abilityType then return nil end
  if not abilities then
    abilities = root.assetJson(abilityTablePath)
  end
  return abilities[abilityType]
end

-- abilitySlot is either "alt" or "primary"
function getAbilitySource(config, parameters, abilitySlot)
  local typeKey = abilitySlot .. "AbilityType"
  local abilityType = parameters[typeKey] or config[typeKey]

  return getAbilitySourceFromType(abilityType)
end

-- Adds the new ability to the config (modifying it)
-- abilitySlot is either "alt" or "primary"
function addAbility(config, parameters, abilitySlot, abilitySource)
  if abilitySource then
    local abilityConfig = root.assetJson(abilitySource)

    -- Rename "ability" key to primaryAbility or altAbility
    local abilityType = abilityConfig.ability.type
    abilityConfig[abilitySlot .. "Ability"] = abilityConfig.ability
    abilityConfig.ability = nil

    -- Allow parameters in the activeitem's config to override the abilityConfig
    local newConfig = util.mergeTable(abilityConfig, config)
    util.mergeTable(config, newConfig)

    parameters[abilitySlot .. "AbilityType"] = abilityType
  end
end

-- Determines ability from config/parameters and then adds it.
-- abilitySlot is either "alt" or "primary"
-- If builderConfig is given, it will randomly choose an ability from
-- builderConfig if the ability is not specified in the config/parameters.
function setupAbility(... --[[config, parameters, abilitySlot, builderConfig, seed]])
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  local config, parameters, abilitySlot, builderConfig, seed =
    Plugins.call_before_initialize_hooks("abilities", ...)
  -- END PLUGIN LOADER --------------------------------------------------------

  seed = seed or parameters.seed or config.seed or 0

  local abilitySource = getAbilitySource(config, parameters, abilitySlot)
  if not abilitySource and builderConfig then
    local abilitiesKey = abilitySlot .. "Abilities"
    if builderConfig[abilitiesKey] and #builderConfig[abilitiesKey] > 0 then
      local abilityType = randomFromList(builderConfig[abilitiesKey], seed, abilitySlot .. "AbilityType")
      abilitySource = getAbilitySourceFromType(abilityType)
    end
  end

  if abilitySource then
    addAbility(config, parameters, abilitySlot, abilitySource)
  end

  -- PLUGIN LOADER ------------------------------------------------------------
  Plugins.call_after_initialize_hooks("abilities")
  -- END PLUGIN LOADER --------------------------------------------------------
end
