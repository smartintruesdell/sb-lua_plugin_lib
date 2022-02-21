--[[ Test Plugin, treat this like data: It's very mutable ]]
--[[
  Unlike the other test plugin, this one exercises methods that are called with
  an attached metatable, such that they're invoked with `self`
]]
require "/scripts/util.lua"
require "/scripts/lpl_plugin_util.lua"

Plugins.debug = true

SpearStab.fire = Plugins.add_before_hook(
  SpearStab.fire,
  function()
    sb.logInfo("Before!")
    if self == nil then
      sb.logInfo("no self in before")
    else
      sb.logInfo("self was valid!")
    end
  end,
  SpearStab
)

SpearStab.fire = Plugins.add_after_hook(
  SpearStab.fire,
  function()
    sb.logInfo("After!")
    if self == nil then
      sb.logInfo("no self in before")
    else
      sb.logInfo("self was valid!")
    end
  end,
  SpearStab
)
