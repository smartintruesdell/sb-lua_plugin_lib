require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/liquidimmunity/liquidimmunity_plugins.config"

function init()
  effect.addStatModifierGroup({
    {stat = "lavaImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
    {stat = "tarImmunity", amount = 1},
    {stat = "waterImmunity", amount = 1},
  })
end
init = PluginLoader.add_plugin_loader("liquidimmunity", PLUGINS_PATH, init)

function update(dt)
end

function uninit()

end
