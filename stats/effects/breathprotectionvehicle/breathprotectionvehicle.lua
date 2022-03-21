require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/breathprotectionvehicle/breathprotectionvehicle_plugins.config"

function init()
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({

    {stat = "lavaImmunity", amount = protection},
    {stat = "poisonStatusImmunity", amount = protection},
    {stat = "breathProtection", amount = protection},
    {stat = "waterImmunity", amount = protection},
    {stat = "wetImmunity", amount = protection},
  })

   script.setUpdateDelta(0)
end
init = PluginLoader.add_plugin_loader("breathprotectionvehicle", PLUGINS_PATH, init)

function input(args)
end

function uninit()
end
