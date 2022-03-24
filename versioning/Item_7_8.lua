-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/Item_7_8_plugins.config"] = true

function update(data)
  -- fossil collectables
  if data.name == "fossildisplay1" or data.name == "fossildisplay3" or data.name == "fossildisplay5" then
    if data.parameters.fossilComplete then
      local firstFossilConfig = root.itemConfig(data.parameters.fossilList[1]).config
      local setCollectables = firstFossilConfig.setCollectables
      if setCollectables then
        data.parameters.collectablesOnPickup = setCollectables
      end
    end
  end

  -- monster collectables
  if data.name == "filledcapturepod" then
    local pet = data.parameters.pets[1].config
    local petConfig = root.monsterParameters(pet.type)
    if petConfig.captureCollectables then
      data.parameters.collectablesOnPickup = petConfig.captureCollectables
    end
  end
  return data
end
