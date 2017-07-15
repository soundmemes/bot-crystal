require "./abstract"
require "../../repositories/sound_posting"

module Soundmemes
  module TelegramBot
    module Actions
      class ChosenInlineResult < Abstract
        @result : ::TelegramBot::ChosenInlineResult
        getter :result

        def initialize(@bot : ::TelegramBot::Bot, result : ::TelegramBot::ChosenInlineResult)
          @result = result.not_nil!
        end

        def call
          Repositories::SoundPosting.create(result.from.not_nil!.id, result.result_id.to_i)
        end
      end
    end
  end
end
