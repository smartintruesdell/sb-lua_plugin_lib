require "/scripts/util.lua"

require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH = "/items/active/effects/entitymarker_plugins.config"

function init() end
init = PluginLoader.add_plugin_loader("entitymarker", PLUGINS_PATH, init)

function update()
  localAnimator.clearDrawables()

  local markerImage = animationConfig.animationParameter("markerImage")
  if markerImage then
    local entities = animationConfig.animationParameter("entities") or {}
    entities = util.filter(entities, world.entityExists)
    for _,entityId in pairs(entities) do
      localAnimator.addDrawable({image = markerImage, position = world.entityPosition(entityId)}, "overlay")
    end
  end
end
