require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/playerbeamin/playerbeamin_plugins.config"

function init()
  effect.addStatModifierGroup({{stat = "invulnerable", amount = 1}})

  world.spawnProjectile(
    "beamdownknockback",
    entity.position(),
    entity.id(),
    {0, 0},
    false
  )
end
init = PluginLoader.add_plugin_loader("playerbeamin", PLUGINS_PATH, init)

function update(_dt) end

function uninit() end
