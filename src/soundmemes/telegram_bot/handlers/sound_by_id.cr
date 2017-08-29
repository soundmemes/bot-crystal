require "../../orm/models/sound"
require "./helpers/sound_information"
require "../keyboards/sound_management_menu"

module Soundmemes
  module TelegramBot
    module Handlers
      class SoundById < Tele::Handlers::Message
        include Helpers::SoundInformation

        REGEXPS = [/^\/(\d+)$/, /^(?:id|#|№)(\d+)$/]

        def call
          if REGEXPS.find &.match(message.text.not_nil!)
            id = $~[1].to_i

            sound = Repo.get(Sound, id, Query.preload(:user))

            if sound
              in_favorites? = !!Repo.get_by(Favorite, user_id: sound.user.id, sound_id: sound.id)

              [
                R::SendVoice.new(
                  chat_id: message.chat.id,
                  voice: sound.telegram_file_id.not_nil!,
                  reply_markup: Keyboards::SoundManagementMenu.new(sound.id.as(Int32), in_favorites?).to_type,
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
