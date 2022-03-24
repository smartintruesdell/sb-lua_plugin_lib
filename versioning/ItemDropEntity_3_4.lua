-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/ItemDropEntity_3_4_plugins.config"] = true

function update(data)
  local item = data.item.content

  -- fossil collectables
  if item.name == "fossildisplay1" or item.name == "fossildisplay3" or item.name == "fossildisplay5" then
    if item.parameters.fossilComplete then
      local firstFossilConfig = root.itemConfig(item.parameters.fossilList[1]).config
      local setCollectables = firstFossilConfig.setCollectables
      if setCollectables then
        item.parameters.collectablesOnPickup = setCollectables
      end
    end
  end

  -- monster collectables
  if item.name == "filledcapturepod" then
    local pet = item.parameters.pets[1].config
    local petConfig = root.monsterParameters(pet.type)
    if petConfig.captureCollectables then
      item.parameters.collectablesOnPickup = petConfig.captureCollectables
    end
  end

  return data
end
