--[[
  This module provides logic for resolving dependencies between plugins.
  Some plugins want to go first!
  Some plugins want to go last!
  Some plugins want to go AFTER or BEFORE other plugins.
  You can do that.
]]
require("/scripts/util.lua")

function reverse(t)
	local len = #t
	for i = len - 1, 1, -1 do
		t[len] = table.remove(t, i)
	end
  return t
end

-- Dependencies Graph ---------------------------------------------------------

local PluginDependenciesNode = {}

function PluginDependenciesNode.new(plugin)
  local node = {}
  assert(plugin.name ~= nil, "Tried to load a plugin with no name")
  node.name = plugin.name
  assert(
    plugin.path ~= nil,
    string.format(
      "Tried to load plugin %s, which had no `path`",
      plugin.name
    )
  )
  node.path = plugin.path
  node.requires = plugin.requires
  node.after = plugin.after

  return node
end

PluginDependencies = {}

function PluginDependencies.resolve(plugins_list)
  -- First, we'll build our initial set of Nodes
  local loaded = {}
  local nodes = {}
  for _, plugin_data in ipairs(plugins_list) do
    local node = PluginDependenciesNode.new(plugin_data)
    if loaded[node.name] ~= nil then
      assert(
        false,
        string.format(
          "Had a unique name collision on plugins: %s. Loaded: %s, Loading: %s",
          node.name,
          loaded[node.name].path,
          node.path
        )
      )
    end
    loaded[node.name] = node
    table.insert(nodes, node)
  end

  -- Plugin resolution
  local function resolve_nodes(nodes_list)
    local results = {}

    local function dep_resolve(node, resolved, resolving)
      resolved = resolved or {}
      resolving = resolving or {}
      resolving[node.name] = true
      for _, req_name in ipairs(node.required or {}) do
        assert(
          loaded[req_name] ~= nil,
          string.format(
            "Unmet dependency while loading plugin %s: %s was not available",
            node.name,
            req_name
          )
        )
        if not resolved[req_name] then
          assert(
            resolving[req_name],
            string.format(
              "Circular plugin dependency detected: %s -> %s",
              node.name,
              req_name
            )
          )
          dep_resolve(
            loaded[req_name],
            resolved,
            resolving
          )
        end
      end
      for _, after_name in ipairs(node.after or {}) do
        if loaded[after_name] then
          if not resolved[after_name] then
            assert(
              resolving[after_name],
              string.format(
                "Circular plugin dependency detected: %s -> %s",
                node.name,
                after_name
              )
            )
            dep_resolve(
              loaded[after_name],
              resolved,
              resolving
            )
          end
        end
      end
      table.insert(results, node)
      resolved[node.name] = true
      resolving[node.name] = false
    end

    for _, node in ipairs(nodes_list) do
      dep_resolve(node)
    end

    return results
  end

  return reverse(resolve_nodes(nodes))
end
