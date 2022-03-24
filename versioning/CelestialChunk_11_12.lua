require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/CelestialChunk_11_12_plugins.config"] = true

function update(data)
  local systemTypes = {}
  for name,type in pairs(root.assetJson("/celestial.config:systemTypes")) do
    systemTypes[type.baseParameters.typeName] = type
  end

  for _,star in pairs(data.systemParameters) do
    local coordinate, systemParameters = star[1], star[2]
    local threatLevel = systemTypes[systemParameters.parameters.typeName].baseParameters.spaceThreatLevel
    if threatLevel == nil then
      error(string.format("No spaceThreatLevel specified for system with typeName %s in celestial.config", systemParameters.parameters.typeName))
    end
    systemParameters.parameters.spaceThreatLevel = threatLevel
  end

  return data
end
