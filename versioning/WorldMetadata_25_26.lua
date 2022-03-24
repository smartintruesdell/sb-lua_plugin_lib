require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_25_26_plugins.config"] = true

function update(data)
  data.dungeonIdBreathable = jarray()

  return data
end
