--[[
  This example is a plugin for /items/active/weapons/weapon.lua which
  demonstrates old and new "hooks", for comparison
]]
require "/scripts/lpl_plugin_util.lua"

-- OLD WAY --------------------------------------------------------------------
-- Remember to save off the old method
local oldGetPrimaryAbility = getPrimaryAbility()
function getPrimaryAbility(...)
  -- Always remember to invoke the old method
  local oldResult = oldGetPrimaryAbility(...)

  local awesomeAbilityConfig = config.getParameter("awesomeAbility")
  if awesomeAbilityConfig then
    return getAbility("awesome", awesomeAbilityConfig)
  end

  return oldResult
end


-- NEW WAY
-- You can load hooks for files in configs that don't normally support it
-- You can specify dependency/load-order for hook plugins
-- You can run both BEFORE and AFTER hooks, instead of hook 'wrappers'
-- You don't have to remember to save the old method
getPrimaryAbility = Plugins.add_after_plugin(
  getPrimaryAbility,
  function (oldResult, ...) -- You get the old result and args automatically

    local awesomeAbilityConfig = config.getParameter("awesomeAbility")
    if awesomeAbilityConfig then
      Plugins.early_out = true -- You can stop processing on other hooks
      return getAbility("awesome", awesomeAbilityConfig)
    end

    return oldResult
  end
)
