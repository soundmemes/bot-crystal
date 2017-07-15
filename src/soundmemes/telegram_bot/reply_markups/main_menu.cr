require "telegram_bot"

module Soundmemes
  module TelegramBot
    module ReplyMarkups
      class MainMenu
        getter :markup

        def initialize
          @markup = ::TelegramBot::ReplyKeyboardMarkup.new([["/new"]], resize_keyboard: true)
        end
      end
    end
  end
end
