require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_24_25_plugins.config"] = true

function update(data)
  data.dungeonIdGravity = {}
  -- Add all the dungeon gravity values
  for _,p in pairs(data.dungeonIdMap) do
    local dungeon = root.dungeonMetadata(p[2])
    if dungeon.gravity then
      table.insert(data.dungeonIdGravity, {p[1], dungeon.gravity})
    end
  end
  data.dungeonIdMap = nil

  -- Also add ZeroGDungeonId and ProtectedZeroGDungeonId
  table.insert(data.dungeonIdGravity, {65524, 0.0})
  table.insert(data.dungeonIdGravity, {65525, 0.0})

  return data
end
