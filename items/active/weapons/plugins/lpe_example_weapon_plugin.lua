--[[
  This is an example weapon plugin. You can use this as a template for your own
  plugins.
]]

-- First, we localize references to the existing Weapon methods.
-- These will be chains of all other plugin Weapon methods and the original Weapon
-- script methods. Note we use the Weapon.method and not Weapon:method forms because
-- we want to pass references directly
--
-- You can omit any of these that you don't plan to modify. If you're not going
-- to override uninit, you don't have to bind a super.
local super_init = Weapon.init
local super_update = Weapon.update

-- There is a special case for 'new', because Weapon.new is where we run the plugin
-- loader so we can't realistically chain it. Instead, we specify Weapon:plugin_new
-- and call that after plugins are loaded
local super_new = Weapon.plugin_new or function (config) return config end

function Weapon.plugin_new(weaponConfig)
  weaponConfig.worksWithPlugins = true
  -- This is the only `super` where we won't pass `self` through.
  return super_new(weaponConfig)
end

-- Amending standard methods is easy, there are two patterns to keep in mind:

function Weapon:init()
  -- You can call the super first,
  -- Always call the `super` method with self and all appropriate arguments
  super_init(self)

  -- And then do additional handling if you want your logic to happen AFTER
  -- your dependencies are resolved
  self.worksWithPlugins = true
end

function Weapon:update(dt, fireMode, shiftHeld)
  -- Or you can do your logic first to apply your logic BEFORE your dependencies.
  self.worksWithPlugins = true

  -- And then call the super method
  -- Always call the `super` method with self and all appropriate arguments.
  return super_update(self, dt, fireMode, shiftHeld)
  -- Note that here we RETURN the result, because update expects the return value
end

-- However, keep in mind that if you forget (or choose not to) call the `super`
-- method that you saved at the top of the script, you can break plugin chaining.
-- Your plugin -> Super()
--    Some dependency -> Super()
--        Vanilla code
