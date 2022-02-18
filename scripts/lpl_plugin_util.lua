--[[
  Helpful utilities for writing Lua script plugins for LuaPluginLib

  Hook logic inspired and derived from
  @see https://github.com/vallentin/hook.lua/blob/master/hook.lua
]]
Plugins = Plugins or {}

-- Hooks ----------------------------------------------------------------------

---@param hfn function @The PluginHookFunction assembed by adding hooks
local function call_hooks(hfn, ...)
  local pargs = table.pack(...)

  -- First, call the "before" hooks, updating the function args
  for i = 1, #hfn.__before_hooks, 1 do
    pargs = table.pack(hfn.__before_hooks[i](table.unpack(pargs)))
  end

  local result = nil
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

--- Build a new PluginHookFunction from a regular function
local function new_hook(fn)
  local hfn = {}

  hfn.__hooks = {}
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

local function is_PluginHookFunction(a)
  if type(a) == "table" and type(a.__before_hooks) == "table" then
    return true
  end
  return false
end

function Plugins.add_before_hook(fn, callback)
  if callback == nil then return fn end

  if type(fn) == "function" then
    return add_before_hook(new_hook(fn), callback)
  elseif is_PluginHookFunction(fn) then
    return add_before_hook(fn, callback)
  end
  return fn
end

function Plugins.add_after_hook(fn, callback)
  if callback == nil then return fn end

  if type(fn) == "function" then
    return add_after_hook(new_hook(fn), callback)
  elseif is_PluginHookFunction(fn) then
    return add_after_hook(fn, callback)
  end
  return fn
end

function Plugins.call(hfn, ...)
  if is_PluginHookFunction(hfn) then
    return call_hooks(hfn, ...)
  end
  return nil
end

function Plugins.remove_before_hook(hfn, callback)
  if is_PluginHookFunction(hfn) then
    for i = #hfn.__before_hooks, 1, -1 do
      if hfn.__before_hooks[i] == callback then
        table.remove(hfn.__before_hooks, i)
      end
    end
    if #hfn.__hooks == 0 then
      return hfn.__fn
    end
  end
  return hfn
end

function Plugins.remove_after_hook(hfn, callback)
  if is_PluginHookFunction(hfn) then
    for i = #hfn.__after_hooks, 1, -1 do
      if hfn.__after_hooks[i] == callback then
        table.remove(hfn.__after_hooks, i)
      end
    end
    if #hfn.__hooks == 0 then
      return hfn.__fn
    end
  end
  return hfn
end

function Plugins.clear_hooks(hfn)
  if is_PluginHookFunction(hfn) then
    hfn.__before_hooks = {}
    hfn.__after_hooks = {}

    return hfn.__fn
  end

  return hfn
end

function Plugins.count_hooks(hfn)
  if is_PluginHookFunction(hfn) then
    return #hfn.__before_hooks + #hfn.__after_hooks
  end
  return 0
end

function Plugins.get_hooks(hfn)
  if is_PluginHookFunction(hfn) then
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
