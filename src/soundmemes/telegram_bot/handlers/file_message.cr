require "./helpers/user_state"
require "./helpers/sound_information"
require "../../jobs/process_file"
require "../keyboards/main_menu"
require "../../../utils/logger"

module Soundmemes
  module TelegramBot
    module Handlers
      class FileMessage < Tele::Handlers::Message
        include UserState
        include Helpers::SoundInformation
        include Utils::Logger

        def call
          case user_state.get
          when US::State::AddSoundSetName, US::State::AddSoundSetTags
            send_message(text: "A text must be sent, not attachment.")
          when US::State::AddSoundUploadFile
            # TODO: If the file is Voice, process immideately
            if message.audio || message.voice || message.document
              params = user_state.get_params
              return send_message(text: "It's not a right time to send an attachment.") unless params["new_sound_name"]?

              tags = params["new_sound_tags"]?
              tags = nil unless tags.try &.size.> 0

              # OPTIMIZE: What the heck? Refer to https://github.com/crystal-lang/crystal/issues/2661
              {% for t in ["audio", "voice", "document"] %}
                if message.{{t.id}}
                  Jobs::ProcessFile.dispatch(message.from.not_nil!.id, message.{{t.id}}.not_nil!.file_id, params["new_sound_name"], tags)
                end
              {% end %}

              user_state.set(US::State::MainMenu)

              send_message(
                text: "Your file is being processed.",
                reply_markup: Keyboards::MainMenu.new.to_type,
              )
            else
              send_message(text: "This attachment type is not supported yet.")
            end
          else
            if message.voice
              sounds = Repo.all(Sound, Query.where(telegram_file_id: message.voice.not_nil!.file_id).preload(:user))

              if sounds.size > 0 && (sound = sounds.first)
                in_favorites? = !!Repo.get_by(Favorite, user_id: sound.user.id, sound_id: sound.id)

                send_message(
                  text: sound_information(sound),
                  parse_mode: "HTML",
                  reply_markup: Keyboards::SoundManagementMenu.new(sound.id.as(Int32), in_favorites?).to_type
                )
              else
                send_message(text: "Could not find this sound in the Database. Consider adding it yourself: /new")
              end
            else
              send_message(text: "It's not a right time to send an attachment.")
            end
          end
        end
      end
    end
  end
end
