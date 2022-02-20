require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH =
  "/items/active/stationtransponder/stationtransponder_plugins.config"

function init()
  if storage.consumed then
    item.consume(1)
    return
  end
  storage.consumed = false

  message.setHandler("holdingTransponder", function() return true end)
  message.setHandler("setTransponderConsumed", function() storage.consumed = true end)
  message.setHandler("consumeTransponder", function() item.consume(1) end)
end
init = PluginLoader.add_plugin_loader("stationtransponder", PLUGINS_PATH, init)

function activate(fireMode, shiftHeld)
  activeItem.interact(config.getParameter("interactAction"), config.getParameter("interactData"));
end

function uninit()
  if storage.consumed and item.count() > 0 then
    item.consume(1)
  end
end
