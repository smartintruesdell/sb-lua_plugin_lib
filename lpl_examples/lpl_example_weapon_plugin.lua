--[[
  This is an example weapon plugin. You can use this as a template for your own
  plugins.
]]
-- Require the Plugins module with useful utilities
require "/scripts/lsl_plugin_util.lua"

-- Name should match the filename of the target of our plugin.
local MODULE_NAME = "weapon"

-- Here, we add our first "Hook". This one will run AFTER the new/init script
-- where plugins are loaded for the module being patched. It's important that
-- your MODULE_NAME name matches the name of the script file you're patching.
Plugins.add_after_initialize_hook(
  MODULE_NAME,
  function (weaponConfig)
    for _, tag in ipairs(weaponConfig.itemTags or {}) do
      if tag == "shortspear" then
        table.insert(weaponConfig.itemTags, "spear")
        break;
      end
    end
    return weaponConfig
  end
)

-- Amending standard methods is easy, there are two patterns to keep in mind:

-- To call code BEFORE a function is called, or to modify its arguements before
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
