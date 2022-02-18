--[[
  Helpful utilities for writing Lua script plugins for LuaPluginLib

  Hook logic inspired and derived from
  @see https://github.com/vallentin/hook.lua/blob/master/hook.lua
]]
Plugins = Plugins or {}

-- Hooks ----------------------------------------------------------------------

---@param hfn function @The Hookable assembed by adding hooks
local function call_hooks(hfn, ...)
  local pargs = table.pack(...)

  -- First, call the "before" hooks, updating the function args
  for i = 1, #hfn.__before_hooks, 1 do
    pargs = table.pack(hfn.__before_hooks[i](table.unpack(pargs)))
  end

  local result = hfn.__fn(table.unpack(pargs))
  local stop = nil
  -- Then, call the "after" hooks, updating the result until we
  -- hit a stop or the end of the list.
  for i = 1, #hfn.__after_hooks, 1 do
    results, stop = hfn.__after_hooks[i](result)
    -- Handle stop return
    if stop ~= nil then break end
  end

  return result
end

--- Build a new Hookable from a regular function
Plugins.Hookable = {}
function Plugins.Hookable.new(fn)
  local hfn = {}
  hfn.is_Hookable = true

  hfn.__before_hooks = {}
  hfn.__after_hooks = {}
  hfn.__fn = fn

  setmetatable(hfn, {
    __call = function(_, ...)
      local res = { call_hooks(hfn, ...) }

      if res ~= nil and #res > 0 then
        return table.unpack(res)
      end

      return hfn.__fn(...)
    end
  })

  return hfn
end

local function add_before_hook(hfn, callback)
  table.insert(hfn.__before_hooks, callback)

  return hfn
end

local function add_after_hook(hfn, callback)
  table.insert(hfn.__after_hooks, callback)

  return hfn
end

local function is_Hookable(a)
  if type(a) == "table" and type(a.__before_hooks) == "table" then
    return true
  end
  return false
end

function Plugins.add_before_hook(fn, callback)
  assert(
    fn ~= nil,
    "Plugins: Cound not add before hook to `nil` - "..
    "ensure your function/method reference is valid"
  )
  assert(
    callback ~= nil,
    "Plugins: Cound not add `nil` before hook to function - "..
    "ensure your hook callback is valid"
  )

  if type(fn) == "function" then
    return add_before_hook(Plugins.Hookable.new(fn), callback)
  elseif is_Hookable(fn) then
    return add_before_hook(fn, callback)
  else
    assert(
      false,
      string.format(
        "Plugins: Could not add a before hook to type '%s'",
        type(fn)
      )
    )
  end

  return fn
end

function Plugins.add_after_hook(fn, callback)
  assert(
    fn ~= nil,
    "Plugins: Cound not add after hook to `nil` - "..
    "ensure your function/method reference is valid"
  )
  assert(
    callback ~= nil,
    "Plugins: Cound not add `nil` after hook to function - "..
    "ensure your hook callback is valid"
  )

  if type(fn) == "function" then
    return add_after_hook(Plugins.Hookable.new(fn), callback)
  elseif is_Hookable(fn) then
    return add_after_hook(fn, callback)
  else
    assert(
      false,
      string.format(
        "Plugins: Could not add a after hook to type '%s'",
        type(fn)
      )
    )
  end

  return fn
end

function Plugins.call(hfn, ...)
  if is_Hookable(hfn) then
    return call_hooks(hfn, ...)
  end
  return nil
end

function Plugins.remove_before_hook(hfn, callback)
  if is_Hookable(hfn) then
    for i = #hfn.__before_hooks, 1, -1 do
      if hfn.__before_hooks[i] == callback then
        table.remove(hfn.__before_hooks, i)
      end
    end
  end
  return hfn
end

function Plugins.remove_after_hook(hfn, callback)
  if is_Hookable(hfn) then
    for i = #hfn.__after_hooks, 1, -1 do
      if hfn.__after_hooks[i] == callback then
        table.remove(hfn.__after_hooks, i)
      end
    end
  end
  return hfn
end

function Plugins.clear_hooks(hfn)
  if is_Hookable(hfn) then
    hfn.__before_hooks = {}
    hfn.__after_hooks = {}

    return hfn.__fn
  end

  return hfn
end

function Plugins.count_hooks(hfn)
  if is_Hookable(hfn) then
    return #hfn.__before_hooks + #hfn.__after_hooks
  end
  return 0
end

function Plugins.get_hooks(hfn)
  if is_Hookable(hfn) then
    local before_hooks = {}
    local after_hooks = {}

    for i=1, #hfn.__before_hooks, 1 do
      table.insert(before_hooks, #hfn.__before_hooks[i])
    end
    for i=1, #hfn.__after_hooks, 1 do
      table.insert(after_hooks, #hfn.__after_hooks[i])
    end

    return before_hooks, after_hooks
  end
  return {}, {}
end

-- Initializer Hooks ----------------------------------------------------------

--[[ These are a little trickier, and require a module name to avoid collisions ]]

Plugins.initialize_hooks = {}
function Plugins.add_before_initialize_hook(module_name, callback)
  assert(
    module_name ~= nil and type(module_name) == string,
    "Plugins: You must provide a module name to add_before_initialize_hook"
  )
  if Plugins.initialize_hooks[module_name] == nil then
    Plugins.initialize_hooks[module_name] = {
      __before_hooks = {},
      __after_hooks = {}
    }
  end
  table.insert(Plugins.initialize_hooks[module_name].__before_hooks, callback)
end
function Plugins.add_after_initialize_hook(module_name, callback)
  assert(
    module_name ~= nil and type(module_name) == string,
    "Plugins: You must provide a module name to add_after_initialize_hook"
  )
  if Plugins.initialize_hooks[module_name] == nil then
    Plugins.initialize_hooks[module_name] = {
      __before_hooks = {},
      __after_hooks = {}
    }
  end
  table.insert(Plugins.initialize_hooks[module_name].__after_hooks, callback)
end

function Plugins.call_before_initialize_hooks(module_name, ...)
  if Plugins.initialize_hooks[module_name] ~= nil then
    for i = 1, #Plugins.initialize_hooks[module_name].__before_hooks, 1 do
      Plugins.initialize_hooks[module_name].__before_hooks[i](...)
    end
  end
end
function Plugins.call_after_initialize_hooks(module_name, ...)
  if Plugins.initialize_hooks[module_name] ~= nil then
    for i = 1, #Plugins.initialize_hooks[module_name].__after_hooks, 1 do
      Plugins.initialize_hooks[module_name].__after_hooks[i](...)
    end
  end

  return ...
end
