require "tele/keyboards/inline"

module Soundmemes
  module TelegramBot
    module Keyboards
      class InlinePagination < Tele::Keyboards::Inline
        BUTTON_BACK = "⬅️ Previous page"
        BUTTON_NEXT = "➡️ Next page"

        # Use:
        # ```
        # InlinePagination.new("favorites", 1, true).to_type
        # ```
        def initialize(name : String, current_page : Int32, anything_left? : Bool)
          buttons = [] of Button
          if current_page > 0
            buttons << Button.new(text: BUTTON_BACK, callback_data: name + ":page" + (current_page - 1).to_s)
          end
          if anything_left?
            buttons << Button.new(text: BUTTON_NEXT, callback_data: name + ":page" + (current_page + 1).to_s)
          end
          @buttons.push(buttons) if buttons.any?
        end
      end
    end
  end
end
