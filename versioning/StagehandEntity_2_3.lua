-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/StagehandEntity_2_3_plugins.config"] = true

function update(data)
  if data.type == "questmanager" then
    if not data.scriptStorage.participantsReserved then
      data.scriptStorage.participantsReserved = true
    end
  end

  return data
end
