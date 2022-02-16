--[[
  This script allows for easy managent of Plugins for existing script modules.

  Instead of making direct edits to the vanilla scripts, we use this script once
  in each of those scripts to load plugins dynamically.
]]
require "/scripts/pb_dependencies.lua"

PluginLoader = {}

---@param config_path string
---@return boolean, table
function PluginLoader.load(config_path)
  local loaded_plugins = {}
  assert(
    root ~= nil,
    "Run `load_plugins` in module new or init. Cannot run in the global context"
  )
  local config_data = root.assetJson(config_path)

  local plugins_to_load = PluginDependencies.resolve(config_data.plugins)

  for _, plugin in ipairs(plugins_to_load) do
    if not loaded_plugins[plugin.name] then
      require(plugin.path)
      loaded_plugins[plugin.name] = true
    end
  end
end
