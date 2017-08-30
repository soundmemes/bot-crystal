require "tele/keyboards/reply"

module Soundmemes
  module TelegramBot
    module Keyboards
      class MainMenu < Tele::Keyboards::Reply
        BUTTON_FAVORITES = "⭐️ Favorites"
        BUTTON_POPULAR   = "🔥 Popular"
        BUTTON_MY_SOUNDS = "🌝 My sounds"
        BUTTON_NEW_SOUND = "⚡️ Add sound"
        BUTTON_MORE      = "👀 Information"
        BUTTON_DONATE    = "☕️ Buy coffee"

        def initialize
          @buttons.push([Button.new(BUTTON_FAVORITES), Button.new(BUTTON_POPULAR)])
          @buttons.push([Button.new(BUTTON_MY_SOUNDS), Button.new(BUTTON_NEW_SOUND)])
          @buttons.push([Button.new(BUTTON_MORE), Button.new(BUTTON_DONATE)])
          super(resize_keyboard: true)
        end
      end
    end
  end
end
