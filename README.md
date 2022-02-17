# LuaPluginLib
A library mod for Starbound which makes Lua scripts little more extensible.


## The problem

Many mods want to update the code in `weapon.lua` or `player_primary.lua`, and doing so risks incompatabilities with other mods.

Whoever loads last, gets to keep their code! That's not great.


## The solution

This mod offers a simple interface for loading "plugins" on top of your lua, and modifies vanilla lua to use its mechanisms.

With LuaPluginLib, you can add a reference to your "plugin" to a local `.config` or `.config.patch` file and supported scripts will layer your code on top of their own.


## Example

Let's imagine you want to update the item tags on all `shortspears` to be `spears`.

You could add `.patch` files for every shortspear ever, or you could add the following files:

**/items/weapons/weapon_plugins.config.patch**
```json
[
    {
        "op": "add",
        "path": "/plugins/-",
        "value": {
            "name": "my_shortspears_weapon_plugin",
            "path": "/my_scripts/my_shortspears_weapon_plugin.lua",
            "requires": [],
            "after": []
        }
    }
]
```

**/my_scripts/my_shortspears_weapon_plugin.lua**
```lua
--[[
  This is my plugin!
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
  for _, tag in ipairs(weaponConfig.itemTags or {}) do
    if tag == "shortspear" then
      table.insert(weaponConfig.itemTags, "spear")
      break;
    end
  end

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
  super_update(self, dt, fireMode, shiftHeld)
end

-- However, keep in mind that if you forget (or choose not to) call the `super`
-- method that you saved at the top of the script, you can break plugin chaining.
-- Your plugin -> Super()
--    Some dependency -> Super()
--        Vanilla code
```

## What "vanilla" scripts get support when I load LuaPluginLib?

Out of the box, LuaPluginLib updates the following vanilla scripts to add patch support:

- `items/active/weapons/weapon.lua`
- `monsters/monster.lua`
- `stats/player_primary.lua`

With more to be added as needed!

These updates do more than just call the PluginLoader: They also non-destructively refactor the vanilla modules into individual functions to make writing your plugins easier.

For example, in `player_primary.lua`, you don't necessarily have to write your plugin to wrap the entire `applyDamageRequest(damageRequest)` method. Instead, you can just wrap `applyDamageRequest_apply_knockback(damageRequest)` subroutine to make your mod that dramatically exaggerates knockback force.


## I need a vanilla script to support patching, what can I do?

If you have the know-how, go ahead and make a pull request. Adding support is easy (see the next section) so give it a shot!

If not, you can always file an issue and someone can get to it when they have availability.


## How do I add support for my lua scripts?

The plugin loader works by "wrapping" functions in layers.

For this to work, your code needs to have an entry-point where those layers can be assembled. A great example is the `new` or `init` method for a player/entity/weapon/etc script, or in an intializer for your module.

`PluginLoader` won't work without access to the `root` table, so be careful not to call it in the global namespace.

> Note: The best lua files for plugin authors are split up into lots of individual subroutine functions so that patches can target specific parts of the logic more easily!
>
> Also, remember you can pass additional data as arguments to your functions even if you're not using them. This can be super valuable for a plugin author down the line!

Here's an example, from `items/active/weapons/weapon.lua`

```lua
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/items/active/weapons/weapon_plugins.config"

function Weapon:new(weaponConfig)
  -- PLUGIN LOADER ------------------------------------------------------------
  PluginLoader.load(PLUGINS_PATH)
  if Weapon.plugin_new ~= nil then
    weaponConfig = Weapon.plugin_new(weaponConfig or {})
  end
  -- END PLUGIN LOADER --------------------------------------------------------

  local newWeapon = weaponConfig or {}
  ...
```

First, we require the plugin loader from `/scripts/lpl_load_plugins.lua`.

Then, we defined where the plugins for this script are going to come from.

Finally, in `Weapon:new`, we invoke `PluginLoader.load(<path>)` to load the plugins `.config` file and its described plugins.

There's an extra bit of note here,
```lua
if Weapon.plugin_new ~= nil then
  weaponConfig = Weapon.plugin_new(weaponConfig or {})
end
```

Because the PluginLoader runs in `Weapon.new`, we can't patch `Weapon.new`.

However, we know we can call arbitrary methods that plugins may have added. So instead we anticipate that one or more may have layered on a `Weapon.plugin_new` method, and we invoke that.

Huzzah! Now our shortspears are all spears.
