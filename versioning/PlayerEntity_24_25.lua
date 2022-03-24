-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/PlayerEntity_24_25_plugins.config"] = true

function update(data)
  data.shipUpgrades.fuelEfficency = 1.0

  return data
end
