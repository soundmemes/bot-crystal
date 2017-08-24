require "../../../utils/logger"
require "../../models/sound"
require "../../repositories/sound"
require "tele/types/inline_query_results/cached_voice"

module Soundmemes
  module TelegramBot
    module Handlers
      class InlineQuery < Tele::Handlers::InlineQuery
        include Utils::Logger

        RECENT_LIMIT    =  3
        MAXIMUM_RESULTS = 50

        def call
          user_id = inline_query.from.not_nil!.id

          mode = case inline_query.query.strip
                 when ""                 then :empty
                 when "recent", ".", "🕗" then :recent
                 else                         :query
                 end

          sounds = [] of Models::Sound
          case mode
          when :empty
            # TODO: Offset
            sounds += Repositories::Sound.recent(user_id, limit: RECENT_LIMIT).map { |s| s.querying_type = Models::Sound::QueryingType::Recent; s }
            limit = MAXIMUM_RESULTS - sounds.size
            sounds += Repositories::Sound.favorites(user_id, limit).reject { |s| sounds.map(&.id).includes?(s.id) }.map { |s| s.querying_type = Models::Sound::QueryingType::Favorite; s }
            limit = MAXIMUM_RESULTS - sounds.size
            if limit > 0
              sounds += Repositories::Sound.popular(limit: limit).reject { |s| sounds.map(&.id).includes?(s.id) }
            end
          when :recent
            sounds += Repositories::Sound.recent(user_id, limit: MAXIMUM_RESULTS).map { |s| s.querying_type = Models::Sound::QueryingType::Recent; s }
          else
            sounds += Repositories::Sound.recent(user_id, limit: RECENT_LIMIT, search_query: inline_query.query).map { |s| s.querying_type = Models::Sound::QueryingType::Recent; s }
            # TODO: Favorites?
            sounds += Repositories::Sound.by_query(search_query: inline_query.query, limit: MAXIMUM_RESULTS - sounds.size).reject { |s| sounds.map(&.id).includes?(s.id) }
          end

          results = [] of Tele::Types::InlineQueryResult
          sounds.each do |sound|
            emoji = ""

            case sound.querying_type
            when Models::Sound::QueryingType::Recent   then emoji = "🕗 "
            when Models::Sound::QueryingType::Favorite then emoji = "⭐️ "
            end

            results << Tele::Types::InlineQueryResults::CachedVoice.new(
              id: sound.id.to_s,
              voice_file_id: sound.telegram_file_id.not_nil!,
              title: emoji + sound.title.not_nil! # TODO: reply_markup
            )
          end

          logger.info("#{results.size} results")

          sw_text, sw_parameter = nil, nil
          case mode
          when :empty
            sw_text = "Tap here to add sound"
            sw_parameter = Start::TOKEN_ADD_NEW_SOUND
          when :recent
            sw_text = "🕗 Recent sounds"
            sw_parameter = Start::TOKEN_ADD_NEW_SOUND
          else
            if sounds.size > 0
              sw_text = "🔎 Search for \"#{inline_query.query}\" (tap to add yours)"
              sw_parameter = Start::TOKEN_ADD_NEW_SOUND
            else
              sw_text = "⚠️ Nothing found. Tap here to add your own sound"
              sw_parameter = Start::TOKEN_ADD_NEW_SOUND
            end
          end

          answer_inline_query(
            results: results,
            is_personal: true,
            cache_time: 0,
            switch_pm_text: sw_text,
            switch_pm_parameter: sw_parameter,
          )
        end
      end
    end
  end
end
