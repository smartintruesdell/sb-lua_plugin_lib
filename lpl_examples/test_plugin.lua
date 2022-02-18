--[[ Test Plugin, treat this like data: It's very mutable ]]
require "/scripts/util.lua"
require "/scripts/lpl_plugin_util.lua"


inflictedDamageCallback_handle_notification = Plugins.add_before_hook(
  inflictedDamageCallback_handle_notification,
  function(notification)
    sb.logInfo("Plugins: BEFORE HOOK CALLED")
    sb.logInfo(util.tableToString(table.pack(notification)))
    return notification
  end
)

inflictedDamageCallback_handle_notification = Plugins.add_before_hook(
  inflictedDamageCallback_handle_notification,
  function(notification)
    sb.logInfo("Plugins: SECOND BEFORE HOOK CALLED")
    sb.logInfo(util.tableToString(table.pack(notification)))
    return notification
  end
)

inflictedDamageCallback_handle_notification = Plugins.add_after_hook(
  inflictedDamageCallback_handle_notification,
  function()
    sb.logInfo("Plugins: AFTER HOOK CALLED")
  end
)

inflictedDamageCallback_handle_notification = Plugins.add_after_hook(
  inflictedDamageCallback_handle_notification,
  function()
    sb.logInfo("Plugins: SECOND AFTER HOOK CALLED")
  end
)
