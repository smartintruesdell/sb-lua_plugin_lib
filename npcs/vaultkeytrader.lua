require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/npcs/vaultkeytrader_plugins.config"

function extraInit()
  message.setHandler("openVaults", extraInit_openVaults_handler)
end
extraInit = PluginLoader.add_plugin_loader("vaultkeytrader", PLUGINS_PATH, extraInit)

function extraInit_openVaults_handler ()
  world.setUniverseFlag("vaultsopen")
end

function handleInteract(args)
  if world.universeFlagSet("vaultsopen") then
    return { "ScriptPane", "/interface/scripted/keytrader/keytradergui.config" }
  else
    sayToEntity({
      dialogType = "dialog.unavailable",
      dialog = nil,
      entity = args.sourceId,
      tags = {}
    })
  end
end


function QuestParticipant:updateOfferedQuests()
  if not world.universeFlagSet("vaultsopen") then
    local offeredQuests = config.getParameter("offeredQuests", jarray())
    npc.setOfferedQuests(offeredQuests)
  end
end
