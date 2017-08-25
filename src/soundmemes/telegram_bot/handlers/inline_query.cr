require "../../../utils/logger"
require "../../orm/models/sound"
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
          query = inline_query.query.strip
          mode = case query
                 when ""                 then :empty
                 when "recent", ".", "🕗" then :recent
                 else                         :query
                 end

          querying_types = {} of UInt64 => QueryingType
          sounds = [] of Sound
          user = User.new.tap &.telegram_id = inline_query.from.not_nil!.id

          case mode
          when :empty
            # TODO: Offset
            sounds += Sound.recent(user, RECENT_LIMIT).tap &.each do |s|
              querying_types[s.hash] = QueryingType::Recent
            end

            limit = MAXIMUM_RESULTS - sounds.size

            sounds += Sound.favorites(user, limit).reject { |s| sounds.map(&.id).includes?(s.id) }.tap &.each do |s|
              querying_types[s.hash] = QueryingType::Favorite
            end

            limit = MAXIMUM_RESULTS - sounds.size

            if limit > 0
              sounds += Sound.popular(limit, %w(id telegram_file_id title)).reject { |s| sounds.map(&.id).includes?(s.id) }
            end
          when :recent
            sounds += Sound.recent(user, MAXIMUM_RESULTS).tap &.each do |s|
              querying_types[s.hash] = QueryingType::Recent
            end
          else
            sounds += Sound.recent(user, RECENT_LIMIT, query).tap &.each do |s|
              querying_types[s.hash] = QueryingType::Recent
            end

            # TODO: Favorites?
            sounds += Sound.search_by_query(query, MAXIMUM_RESULTS - sounds.size).reject { |s| sounds.map(&.id).includes?(s.id) }
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
              sw_text = "🔎 Search for \"#{query}\" (tap to add yours)"
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
