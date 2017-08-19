require "tele/keyboards/reply"

module Soundmemes
  module TelegramBot
    module Keyboards
      class MainMenu < Tele::Keyboards::Reply
        def initialize
          @buttons.push([Button.new("/new")])
          super(resize_keyboard: true)
        end
      end
    end
  end
end
