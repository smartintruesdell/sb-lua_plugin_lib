--[[
  This example is a plugin for /items/active/weapons/weapon.lua
  which demonstrates the two kinds of hooks:
  - initializer hooks
  - standard hooks
]]
-- Require the Plugins module with useful utilities
require "/scripts/lsl_plugin_util.lua"

-- INITIALIZER HOOK -----------------------------------------------------------

-- Name should match the filename of the target of our plugin.
-- Because we can't replace Weapon:new directly (it loads the plugins in the
-- first place), we specify the module name so that the plugin loader knows
-- what hooks to call.
local MODULE_NAME = "weapon"

-- This hook will run BEFORE the new/init script, and allows us to modify
-- the argumenets being passed into Weapon:new
Plugins.add_before_initialize_hook(
  MODULE_NAME,
  function (weaponConfig)
    -- Weapon:new sets a default, so we will too to handle nil configs
    weaponConfig = weaponConfig or {}

    -- For each item tag,
    for _, tag in ipairs(weaponConfig.itemTags or {}) do
      -- if this item is a shortspear,
      if tag == "shortspear" then
        -- let's make sure it's also a spear.
        table.insert(weaponConfig.itemTags, "spear")
        break
      end
    end

    -- Then we return our modified arguments which are passed into
    -- Weapon:new as normal.
    return weaponConfig
  end
)

-- STANDARD Hooks -------------------------------------------------------------

-- Amending standard methods is easy, there are two patterns to keep in mind:

-- To call code BEFORE a function is called, or to modify its arguments before
-- they're applied, use `Plugins.add_before_hook`. Note that we do assignment
-- here:
-- <function> = Plugins.add_before_hook(<function>, <your hook>)

Weapon.update = Plugins.add_before_hook(
  Weapon.update,
  function(_self, dt, fireMode, shiftHeld)
    -- Weapon:update is called as a member of a Weapon instance (with the `:`),
    -- so we get a reference to `self` in the first argument of our
    -- before/after hooks

    -- Here, we can do some work that will apply BEFORE `Weapon.update` is called.
    if shiftHeld then
      sb.logInfo("Player held shift!")
    end

    -- But then we need to return any (non-self) arguments we were given.
    -- It's fine if you want to update them, but return them in the order they
    -- were given to you.

    fireMode = "awesome"

    return dt, fireMode, shiftHeld
  end
)

-- To call code AFTER a function is called, or to modify its return value,
-- use `Plugins.add_after_hook`. Note that we do assignment here:
-- <function> = Plugins.add_after_hook(<function>, <your hook>)

knockbackMomentum = Plugins.add_after_hook(
  knockbackMomentum,
  function(momentum)
    -- Here we receive the last return value for the function we're attached
    -- to, and can modify it before execution continues.

    -- This method is called without a reference to `self`, so we don't get
    -- it.

    -- If you return a non-nil second value, then you can stop additional
    -- hooks from firing. If your code wants to say: "If X, abort",
    -- `return nil, true`
    return { momentum[1] * 1.5, momentum[2] * 1.5 }
  end
)
