require "../../orm/models/sound"

module Soundmemes
  module TelegramBot
    module Handlers
      class SoundById < Tele::Handlers::Message
        REGEXPS = [/^\/(\d+)$/, /^(?:id|#|№)(\d+)$/]

        def call
          if REGEXPS.find &.match(message.text.not_nil!)
            id = $~[1].to_i

            sound = Repo.get(Sound, id, Query.preload(:user).select(%w(title tags telegram_file_id))).try &.as(Sound)

            if sound
              posts_count = Repo.aggregate(SoundPost, :count, :id, Query.where(sound_id: id))

              text = "<b>%{title}</b>\nby %{author}\n\n<b>Tags:</b> %{tags}\n<b>Used:</b> %{used_times} time(s)\n<b>ID</b>: /%{id}" % {
                title:      escape_string(sound.title.not_nil!),
                author:     "<a href=\"tg://user?id=%s\">this memer</a>" % sound.user.telegram_id,
                id:         sound.id,
                tags:       sound.tags,
                used_times: posts_count,
              }

              [
                R::SendVoice.new(
                  chat_id: message.chat.id,
                  voice: sound.telegram_file_id.not_nil!,
                ),
                send_message(
                  text: text,
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

        def escape_string(s)
          s.gsub("<", "&lt;").gsub(">", "&gt;").gsub("&", "&amp;")
        end
      end
    end
  end
end
