require "/scripts/lpl_load_plugins.lua"
local PLUGINS_PATH =
  "/stats/effects/blink/blink_plugins.config"

function init()
  self.blinkOut = config.getParameter("blinkOut")
  self.blinkIn = config.getParameter("blinkIn")

  if self.blinkOut then
    animator.setAnimationState("blink", "blinkout")
    effect.setParentDirectives("?multiply=ffffff00")
    animator.playSound("activate")
  elseif self.blinkIn then
    animator.setAnimationState("blink", "blinkin")
  end
end
init = PluginLoader.add_plugin_loader("blink", PLUGINS_PATH, init)

function update(dt)
  if animator.animationState("blink") == "none" then
    if self.blinkOut and self.blinkIn then
      effect.setParentDirectives("")
      animator.setAnimationState("blink", "blinkin")
    else
      effect.expire()
    end
  end
end

function uninit()
end
