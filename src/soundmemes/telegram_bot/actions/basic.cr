require "telegram_bot"
require "./abstract"
require "./helpers/user_state"

module Soundmemes
  module TelegramBot
    module Actions
      abstract class Basic < Abstract
        include Helpers::UserState

        @message : ::TelegramBot::Message
        getter :message

        def initialize(@bot : ::TelegramBot::Bot, message : ::TelegramBot::Message)
          @message = message.not_nil!
        end

        def user_id
          message.from.not_nil!.id
        end
      end
    end
  end
end
