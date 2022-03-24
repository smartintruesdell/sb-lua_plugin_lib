require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/System_1_2_plugins.config"] = true

function update(data)
  -- set spawn time of permanent objects
  -- remove non-permanent objects
  local keep = jarray()
  for _,object in pairs(data.objects) do
    if root.systemObjectTypeConfig(object.name).permanent then
      object.spawnTime = 0
      table.insert(keep, object)
    end
  end
  data.objects = keep

  -- set last spawn to be at the beginning of time
  -- this is later clamped to be a minimum of systemworld.config::objectSpawnCycle in the past
  data.lastSpawn = 0;
  return data
end
