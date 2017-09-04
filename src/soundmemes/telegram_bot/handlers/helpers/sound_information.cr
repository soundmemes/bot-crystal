require "../../user_state"
require "../../../orm/models/sound"

module Soundmemes::TelegramBot::Handlers
  module Helpers::SoundInformation
    enum SoundInfoVariant
      Full
      Short
    end

    # The resulting request should have {parse_mode: "HTML"}
    def sound_information(sound : Sound, information_variant : SoundInfoVariant = SoundInfoVariant::Full) : String
      case information_variant
      when SoundInfoVariant::Full
        "<b>%{title}</b>\nby %{author}\n\n<b>Tags:</b> %{tags}\n<b>Total usages:</b> %{usages_count}\n<b>ID</b>: /%{id}" % {
          title:        escape_string(sound.title.not_nil!),
          author:       "anonymous",
          id:           sound.id,
          tags:         sound.tags,
          usages_count: sound.agg_postings_count,
        }
      else
        "<b>%{title}</b> (/%{id})\nby %{author}\n%{usages_count} total usage(s)" % {
          id:           sound.id,
          title:        escape_string(sound.title.not_nil!),
          author:       "anonymous",
          usages_count: sound.agg_postings_count,
        }
      end
    end

    def short_sound_information(sound)
      sound_information(sound, SoundInfoVariant::Short)
    end

    def escape_string(s)
      s.gsub("<", "&lt;").gsub(">", "&gt;").gsub("&", "&amp;")
    end
  end
end
