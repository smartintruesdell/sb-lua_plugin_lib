require "/scripts/versioningutils.lua"
-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/WorldMetadata_21_22_plugins.config"] = true

function update(data)
  executeWhere(data, nil, "acidrain", function(object)
      if object.parameters and object.parameters.power then
        object.parameters.power = 0
      end
    end)

  return data
end
