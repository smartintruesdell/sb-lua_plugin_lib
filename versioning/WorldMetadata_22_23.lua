require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_22_23_plugins.config"] = true

function update(data)
  transformInData(data, "weatherPool", function(pool)
      local newPool = jarray()
      for i, weatherPair in ipairs(pool) do
        table.insert(newPool, {weatherPair[1], weatherPair[2].name})
      end
      return newPool
    end)

  return data
end
