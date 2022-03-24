require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_20_21_plugins.config"] = true

function update(data)
  if data.worldTemplate.worldParameters and data.worldTemplate.worldParameters.typeName == "moon" then
    replaceInData(data, "threatLevel", 10, 1)
    replaceInData(data, "spawnTypes", nil, jarray())
  end

  return data
end
