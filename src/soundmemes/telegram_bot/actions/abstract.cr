require "telegram_bot"

module Soundmemes
  module TelegramBot
    module Actions
      abstract class Abstract
        getter :bot

        abstract def call
      end
    end
  end
end
