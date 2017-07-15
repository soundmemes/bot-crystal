require "./environment"
require "uri"
require "./initializers/dispatch/schedule_jobs"
require "./soundmemes/telegram_bot/bot"
require "./soundmemes/version"

Log.info("Launching Soundmemes version #{Soundmemes::VERSION}")

begin
  schedule_jobs

  webhook_port = begin
    ENV["BOT_WEBHOOK_PORT"].to_i
  rescue
    nil
  end

  uri = URI.new(scheme: "https", host: ENV["BOT_WEBHOOK_HOST"], port: webhook_port)

  bot = Soundmemes::TelegramBot::Bot.new
  bot.set_webhook(uri.to_s)
  bot.serve("0.0.0.0", ENV["PORT"].to_i)
ensure
  db.close
end
