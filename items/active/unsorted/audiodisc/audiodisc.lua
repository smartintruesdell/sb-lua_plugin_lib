require "/scripts/lpl_load_plugins.lua"

local PLUGINS_PATH = "/items/active/unsorted/audiodisc/audiodisc_plugins.config"

function init() end

function activate()
  local defaultPortrait = get_defaultPortrait()
  local defaultPortraitFrames = get_defaultPortraitFrames()
  local defaultSenderName = get_defaultSenderName()
  local radioMessages = get_radioMessages()

  send_radioMessages(
    radioMessages,
    defaultPortrait,
    defaultPortraitFrames,
    defaultSenderName
  )

  send_event_notification()

  item.consume(1)
end
activate = PluginLoader.add_plugin_loader("audiodisc", PLUGINS_PATH, activate)

function get_defaultPortrait()
  local defaultPortrait = config.getParameter("defaultPortrait")

  return defaultPortrait
end

function get_defaultPortraitFrames()
  local defaultPortraitFrames = config.getParameter("defaultPortraitFrames")

  return defaultPortraitFrames
end

function get_defaultSenderName()
  local defaultSenderName = config.getParameter("defaultSenderName")

  return defaultSenderName
end

function get_radioMessages()
  local radioMessages = config.getParameter("radioMessages", {})

  return radioMessages
end

function send_radioMessages(
    radioMessages,
    defaultPortrait,
    defaultPortraitFrames,
    defaultSenderName
)
  for i, message in ipairs(radioMessages) do
    if type(message) == "string" then
      message = build_radioMessage_from_string(message, i)
    end

    message.senderName = message.senderName or defaultSenderName

    if not message.portraitImage then
      message.portraitImage = defaultPortrait
      message.portraitFrames = defaultPortraitFrames
    end

    player.radioMessage(message)
  end
end

function build_radioMessage_from_string(message_str, i)
  return {
    messageId = "audioDiscMessage"..i,
    unique = false,
    text = message_str
  }
end

function send_event_notification()
  local messageType = config.getParameter("questId", "") .. ".participantEvent"
  world.sendEntityMessage(activeItem.ownerEntityId(), messageType, nil, "foundClue")
end
