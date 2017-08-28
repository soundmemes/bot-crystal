require "../../user_state"
require "../../../orm/models/sound"

module Soundmemes::TelegramBot::Handlers
  module Helpers::SoundInformation
    # The resulting request should have {parse_mode: "HTML"}
    def sound_information(sound : Sound)
      sound.user = Repo.get(User, sound.user_id) unless sound.user?
      sound.posts_count ||= Repo.aggregate(SoundPost, :count, :id, Query.where(sound_id: sound.id)).as(Int64)

      "<b>%{title}</b>\nby %{author}\n\n<b>Tags:</b> %{tags}\n<b>Used:</b> %{used_times} time(s)\n<b>ID</b>: /%{id}" % {
        title:      escape_string(sound.title.not_nil!),
        author:     "<a href=\"tg://user?id=%s\">this memer</a>" % sound.user.telegram_id,
        id:         sound.id,
        tags:       sound.tags,
        used_times: sound.posts_count,
      }
    end

    def escape_string(s)
      s.gsub("<", "&lt;").gsub(">", "&gt;").gsub("&", "&amp;")
    end
  end
end
