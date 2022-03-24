require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/PlayerEntity_29_30_plugins.config"] = true

function update(data)
  data.shipUpgrades.maxFuel = root.assetJson("/ships/shipupgrades.config:maxFuel")
  data.shipUpgrades.fuelEfficiency = root.assetJson("/ships/shipupgrades.config:fuelEfficiency")
  data.shipUpgrades.shipSpeed = root.assetJson("/ships/shipupgrades.config:shipSpeed")

  return data
end
