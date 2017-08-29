require "tele/keyboards/inline"

module Soundmemes
  module TelegramBot
    module Keyboards
      class SoundManagementMenu < Tele::Keyboards::Inline
        FAVORITE_REGEX = /favorites:switch:(\d+)/

        def initialize(sound_id : Int32, remove_from_favorites? : Bool)
          text = remove_from_favorites? ? "❌ Remove from favorites" : "⭐️ Add to favorites"

          @buttons << [
            Button.new(text: text, callback_data: "favorites:switch:#{sound_id}"),
          ]
        end
      end
    end
  end
end
