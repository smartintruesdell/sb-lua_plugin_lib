require "/scripts/util.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/achievements/achievement_plugins.config"] = true

local operators = {}

function check(achievement)
  for _, stat in ipairs(config.getParameter("stats")) do
    if not checkStat(stat) then
      return false
    end
  end
  return true
end

function checkStat(stat)
  local statValue = statistics.stat(stat.name)
  local op = operators[stat.op]
  assert(op ~= nil)
  return op(stat, statValue)
end

function operators.atLeast(args, currentValue)
  args = applyDefaults(args, {
      default = 0,
      value = 1
    })
  return (currentValue or args.default) >= args.value
end

function operators.atMost(args, currentValue)
  args = applyDefaults(args, {
      default = 0,
      value = 1
    })
  return (currentValue or args.default) <= args.value
end

function operators.sizeAtLeast(args, currentValue)
  args = applyDefaults(args, {
      default = {},
      value = 1
    })
  return util.tableSize(currentValue or args.default) >= args.value
end
