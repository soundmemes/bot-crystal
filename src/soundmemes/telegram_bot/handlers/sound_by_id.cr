require "../../orm/models/sound"
require "./helpers/sound_information"

module Soundmemes
  module TelegramBot
    module Handlers
      class SoundById < Tele::Handlers::Message
        include Helpers::SoundInformation

        REGEXPS = [/^\/(\d+)$/, /^(?:id|#|№)(\d+)$/]

        def call
          if REGEXPS.find &.match(message.text.not_nil!)
            id = $~[1].to_i

            sound = Repo.get(Sound, id)

            if sound
              [
                R::SendVoice.new(
                  chat_id: message.chat.id,
                  voice: sound.telegram_file_id.not_nil!,
                ),
                send_message(
                  text: sound_information(sound),
                  parse_mode: "HTML",
                ),
              ]
            else
              send_message(text: "No sound found with id #{id}.")
            end
          else
            raise ArgumentError.new("A message text doesn't contain sound id! Text: #{message.text}")
          end
        end
      end
    end
  end
end
