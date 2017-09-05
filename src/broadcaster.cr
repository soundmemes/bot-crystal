require "./environment"

token = ENV["BOT_API_TOKEN"]

require "tele-broadcast/worker"
require "tele-broadcast/repositories/redis"
require "./services/redis"

logger = Logger.new(STDOUT).tap(&.level = ENV["APP_ENV"] == "production" ? Logger::INFO : Logger::DEBUG)
repo = Tele::Broadcast::Repositories::Redis.new(redis, logger, "soundmemes:telegram_bot:broadcast:")
worker = Tele::Broadcast::Worker.new(token, repo, logger)

worker.run
