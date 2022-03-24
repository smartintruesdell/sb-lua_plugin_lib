require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_23_24_plugins.config"] = true

function update(data)
  transformInData(data, "worldParameters", function(worldParameters)
      if worldParameters.type == "AsteroidsWorldParameters" then
        worldParameters.worldEdgeForceRegions = "TopAndBottom"
        worldParameters.gravity = 0
      else
        worldParameters.worldEdgeForceRegions = "Top"
      end

      return worldParameters
    end)

  return data
end
