require "./environment"
require "option_parser"

recipients = [] of Int32
text = ""
percentage = 1.0
parse_mode = nil.as(String?)
sound_id = nil.as(Int32?)

# Example:
# crystal src/broadcast-client.cr -- -t 'Hello there\nHow are *you*?!' --parsemode Markdown -p 0.5

OptionParser.parse! do |parser|
  parser.banner = "Usage: src/broadcast/client [arguments]"
  parser.on("-t TEXT", "--text TEXT", "Text to broadcast") { |t| text = t.gsub("\\n", "\n") }
  parser.on("--parse_mode PARSEMODE", "Parse mode (\"Markdown\" or \"HTML\")") { |pm| parse_mode = pm }
  parser.on("-p PERCENT", "--percantage PERCENT", "A percent of users to send, where \"0.05\" is 5%") { |pct| percentage = pct.to_f }
  parser.on("-s SOUND_ID", "--sound SOUND_ID", "Sound ID to post") { |id| sound_id = id.to_i }
  parser.on("-h", "--help", "Show help") { puts parser; exit }
end

raise ArgumentError.new("No text is given!") if text.empty?

require "tele-broadcast/repositories/redis"
require "tele-broadcast/client"
require "./services/redis"

logger = Logger.new(STDOUT).tap(&.level = Logger::INFO)
repo = Tele::Broadcast::Repositories::Redis.new(redis, logger, "soundmemes:telegram_bot:broadcast:")
client = Tele::Broadcast::Client.new(repo, logger)

require "tele/requests/send_message"
requests = [Tele::Requests::SendMessage.new(chat_id: 0, text: text, parse_mode: parse_mode)] of Tele::Request(Tele::Types::Message)

require "tele/requests/send_voice"
require "./soundmemes/orm/models/sound"
if sound_id
  sound = Soundmemes::Repo.get(Soundmemes::Sound, sound_id)
  raise ArgumentError.new("Sound not found with id #{sound_id}!") unless sound

  requests << Tele::Requests::SendVoice.new(chat_id: 0, voice: sound.telegram_file_id.not_nil!)
end

require "./soundmemes/orm/models/user"
recipients = Soundmemes::Repo.all(Soundmemes::User, Query.select(["telegram_id"]))
recipients = recipients.sample((recipients.size * percentage).floor.to_i).as(Array(Soundmemes::User)).map &.telegram_id.not_nil!.to_i

if recipients.any?
  logger.info("Will broadcast to #{recipients.size} users (#{(percentage * 100.0).round(2)}%)")
  client.broadcast(requests, recipients)
end
