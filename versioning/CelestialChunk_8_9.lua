require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/CelestialChunk_8_9_plugins.config"] = true

function update(data)
  executeWhere(data, "typeName", "moon", function(moon)
      replaceInData(moon, "threatLevel", 10, 1)
      replaceInData(moon, "biome", "atmosphere", "void")
      replaceInData(moon, "biome", "asteroids", "barrenasteroids")
    end)

  return data
end
