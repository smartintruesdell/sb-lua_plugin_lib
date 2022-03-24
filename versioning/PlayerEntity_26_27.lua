-- Set a global table so that we can detect modules that are loaded and need
-- plugin patching but which do not have an init method for hooks.
LPL_Additional_Paths = LPL_Additional_Paths or {}
LPL_Additional_Paths["/versioning/PlayerEntity_26_27_plugins.config"] = true

function update(data)
  data.inventory.itemBags = jobject()

  local bags = {"mainBag", "materialBag", "objectBag", "reagentBag", "foodBag"}
  for _,bag in ipairs(bags) do
    data.inventory.itemBags[bag] = data.inventory[bag]
    data.inventory[bag] = nil
  end

  return data
end
