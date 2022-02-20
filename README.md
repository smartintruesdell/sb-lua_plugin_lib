[![LuaPluginLib CI/CD Release process](https://github.com/smartintruesdell/sb-lua_plugin_lib/actions/workflows/main.yml/badge.svg)](https://github.com/smartintruesdell/sb-lua_plugin_lib/actions/workflows/main.yml)
[![GPL-3.0 License](https://img.shields.io/github/license/smartintruesdell/sb-lua_plugin_lib)](https://github.com/smartintruesdell/sb-lua_plugin_lib/blob/main/LICENSE)

# LuaPluginLib
A library mod for Starbound which makes Lua scripts little more extensible.


## The problem

Many mods want to update the code in `weapon.lua` or `player_primary.lua`, and doing so risks incompatabilities with other mods.

Whoever loads last, gets to keep their code! That's not great.


## The solution

This mod offers a simple interface for loading "plugins" on top of your lua, and modifies vanilla lua to use its mechanisms.

With LuaPluginLib, you can add a reference to your "plugin" to a local `.config` or `.config.patch` file and supported scripts will layer your code on top of their own.

LuaPluginLib also adds utilties for adding `hooks` to functions, which allows you to execute your code BEFORE a function or AFTER that function is called.

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
-- Require the Plugins module with useful utilities
require "/scripts/lsl_plugin_util.lua"

-- Name should match the json patch above.
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
  function(self, dt, fireMode, shiftHeld)
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

    -- If you return a non-nil second value, then you can stop additional
    -- hooks from firing. If your code wants to say: "If X, abort",
    -- `return nil, true`
    return { momentum[1] * 1.5, momentum[2] * 1.5 }
  end
)

```

## What "vanilla" scripts get support when I load LuaPluginLib?

Out of the box, LuaPluginLib updates the following vanilla scripts to add plugin support:

<details>
  <summary>Click to see supported scripts</summary>

- /items
  - /active
    - /fishingrod/`fishingrod.lua`
    - /shields/`shield.lua`
    - /vehiclecontroller/`vehiclecontroller.lua`
    - /weapons
      - `weapon.lua`
      - /boomerang/`boomerang.lua`
      - /bossdrop
        - /miniknoglauncher/`rocketstack.lua`
      - /fist
        - `fistweapon.lua`
        - `punch.lua`
      - /melee
        - `energymeleeweapon.lua`
        - `meleecombo.lua`
        - `meleeslash.lua`
        - `meleeweapon.lua`
        - /abilities
          - /axe/`axecleave.lua`
          - /broadsword
            - /bladecharge/`bladecharge.lua`
            - /downstab/`downstab.lua`
            - /flipslash/`flipslash.lua`
            - /parry/`parry.lua`
      - /ranged
        - `gun.lua`
        - `gunfire.lua`
      - /staff/`staff.lua`
      - /whip
        - `whip.lua`
        - /abilities
          - `energyorb.lua`
          - `whipcrack.lua`
  - /buildscripts
    - `abilities.lua`
    - `buildbow.lua`
    - `buildfishingrod.lua`
    - `buildfist.lua`
    - `buildfood.lua`
    - `buildmechpart.lua`
    - `buildsapling.lua`
    - `buildshield.lua`
    - `buildweapon.lua`
    - `buildunrandweapon.lua`
    - `buildunrandshield.lua`
    - `buildwhip.lua`
- /monsters/`monster.lua`
- /scripts
  - /companions
    - `capturable.lua`
    - `crewbenefits.lua`
    - `petspawner.lua`
    - `player.lua`
    - `recruitable.lua`
    - `recruitspawner.lua`
  - /quest
    - /manager
      - `add_tenant.lua`
      - `plugin.lua`
      - `spawn_entities.lua`
- /stats
  - `monster_primary.lua`
  - `npc_primary.lua`
  - `player_primary.lua`
- /vehicles
  - /modularmech
    - /armscripts
      - `base.lua`
      - `beamarm.lua`
      - `boomerangarm.lua`
      - `dasharm.lua`
      - `despawnarm.lua`
      - `drillarm.lua`
      - `dronelauncher.lua`
      - `gatlingarm.lua`
      - `gunarm.lua`
      - `meleearm.lua`
      - `missileburstarm.lua`
      - `remotedetonatorarm.lua`
</details>

With more to be added as needed!

These updates do more than just call the PluginLoader: They also non-destructively refactor the vanilla modules into individual functions to make writing your plugins easier.

For example, in `player_primary.lua`, you don't necessarily have to write your plugin to wrap the entire `applyDamageRequest(damageRequest)` method. Instead, you can just wrap `applyDamageRequest_apply_knockback(damageRequest)` subroutine to make your mod that dramatically exaggerates knockback force.


## I need a vanilla script to support patching, what can I do?

If you have the know-how, go ahead and make a pull request. Adding support is easy (see the next section) so give it a shot!

If not, you can always file an issue and someone can get to it when they have availability.


## How do I add support for my lua scripts?

The plugin loader works by "wrapping" functions in layers.

For this to work, your code needs to have an entry-point where those layers can be assembled. A great example is the `new` or `init` method for a player/entity/weapon/etc script, or in an intializer for your module.


Here's an example, from `items/active/weapons/weapon.lua`

```lua
require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH = "/items/active/weapons/weapon_plugins.config"

function Weapon:new(weaponConfig)
  ...

  return newWeapon
end

Weapon.new = PluginLoader.add_plugin_loader("weapon", PLUGINS_PATH, Weapon.new)
```

First, we require the `PluginLoader` module from `/scripts/lpl_load_plugins.lua`.

After `Weapon:new` is defined, we reassign it the result of `PluginLoader.add_plugin_loader(<filename>, <path>, <method>)`.

This wraps the Weapon.new function with our PluginLoader and activates the `initialization_hooks` described above, all in a single line of code.

It's important that the `<filename>` part of that invocation match the name of the file, as it helps the plugin loader know which initialization hooks to run.

It really **is** that easy. Just one line of code, after your `init` or `new` script, and you're all set.
