require "../../repositories/sound_posting"

module Soundmemes
  module TelegramBot
    module Handlers
      class ChosenInlineResult < Tele::Handler
        def call
          result = update.chosen_inline_result.not_nil!

          # Ensure the user exists
          Repositories::User.new(db).create?(result.from.not_nil!.id)

          Repositories::SoundPosting.new(db).create(result.from.not_nil!.id, result.result_id.to_i)

          nil
        end
      end
    end
  end
end
