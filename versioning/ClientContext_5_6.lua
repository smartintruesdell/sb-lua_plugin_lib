-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/ClientContext_5_6_plugins.config"] = true

function update(data)
  data.shipCoordinate = data.celestialLog.currentWorld
  data.systemLocation = {"coordinate", data.celestialLog.currentWorld}
  data.celestialLog = nil
  return data
end
