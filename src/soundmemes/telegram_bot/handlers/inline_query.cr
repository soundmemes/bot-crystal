require "../../../utils/logger"
require "../../repositories/sound"
require "tele/types/inline_query_results/cached_voice"

module Soundmemes
  module TelegramBot
    module Handlers
      class InlineQuery < Tele::Handlers::InlineQuery
        include Utils::Logger

        RECENT_LIMIT    =  3
        MAXIMUM_RESULTS = 50

        enum QueryingType
          Recent
          Favorite
        end

        def call
          user_id = inline_query.from.not_nil!.id

          mode = case inline_query.query.strip
                 when ""                 then :empty
                 when "recent", ".", "🕗" then :recent
                 else                         :query
                 end

          repository = Repositories::Sound.new(db)
          querying_types = {} of Int32 => QueryingType
          sounds = [] of Entities::Sound

          # TODO: Replace #map with #each
          case mode
          when :empty
            # TODO: Offset
            sounds += repository.recent(user_id, limit: RECENT_LIMIT).map do |s|
              querying_types[s.hash] = QueryingType::Recent; s
            end

            limit = MAXIMUM_RESULTS - sounds.size

            sounds += repository.favorites(user_id, limit).reject { |s| sounds.map(&.id).includes?(s.id) }.map do |s|
              querying_types[s.hash] = QueryingType::Favorite; s
            end

            limit = MAXIMUM_RESULTS - sounds.size

            if limit > 0
              sounds += repository.popular(limit: limit).reject { |s| sounds.map(&.id).includes?(s.id) }
            end
          when :recent
            sounds += repository.recent(user_id, limit: MAXIMUM_RESULTS).map do |s|
              querying_types[s.hash] = QueryingType::Recent; s
            end
          else
            sounds += repository.recent(user_id, limit: RECENT_LIMIT, search_query: inline_query.query).map do |s|
              querying_types[s.hash] = QueryingType::Recent; s
            end

            # TODO: Favorites?
            sounds += repository.by_query(search_query: inline_query.query, limit: MAXIMUM_RESULTS - sounds.size).reject { |s| sounds.map(&.id).includes?(s.id) }
          end

          results = [] of Tele::Types::InlineQueryResult
          sounds.each do |sound|
            emoji = ""

            case querying_types[sound.hash]?
            when QueryingType::Recent   then emoji = "🕗 "
            when QueryingType::Favorite then emoji = "⭐️ "
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
