require "../../interactors/create_sound_post"

module Soundmemes
  module TelegramBot
    module Handlers
      class ChosenInlineResult < Tele::Handler
        def call
          result = update.chosen_inline_result.not_nil!

          Interactors::CreateSoundPost.new(
            telegram_id: result.from.not_nil!.id,
            sound_id: result.result_id.to_i,
          ).call

          nil # Do not answer to the request
        end
      end
    end
  end
end
