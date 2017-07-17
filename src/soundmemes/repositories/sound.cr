require "./base"
require "./user"
require "../models/sound"
require "../models/user"

module Soundmemes
  module Repositories
    class Sound < Base
      module SQL
        extend self
        Tren.load("#{__DIR__}/tren/sound.sql")
      end

      def self.create(telegram_user_id : Int32, title : String, tags : String | Nil, telegram_file_id : String)
        user_id = User.by_telegram_id!(telegram_user_id).id

        data = {
          "user_id"          => user_id,
          "title"            => title,
          "tags"             => tags,
          "telegram_file_id" => telegram_file_id,
          "created_at"       => Time.now,
        }

        db.exec(builder.table("sounds").insert(data))
      end

      def self.recent(telegram_user_id : Int32, limit : Int32 = 10, search_query : String? = nil) : Array(Models::Sound)
        q = if search_query
              SQL.recent(telegram_user_id, search_query.gsub("'", "''"), limit)
            else
              SQL.recent(telegram_user_id, limit)
            end

        Array(Models::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Models::Sound.new(
              id: rs.read(Int32),
              user: Models::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
              created_at: rs.read(Time),
            )

            # Distances
            if search_query
              rs.read(Int32)
              rs.read(Int32)
            end
          end
        end
      end

      def self.favorites(telegram_user_id : Int32) : Array(Models::Sound)
        q = SQL.favorites(telegram_user_id)

        Array(Models::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Models::Sound.new(
              id: rs.read(Int32),
              user: Models::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
            )
          end
        end
      end

      def self.popular(limit : Int32 = 10) : Array(Models::Sound)
        q = SQL.by_popularity(limit)

        Array(Models::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Models::Sound.new(
              id: rs.read(Int32),
              user: Models::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
            )
          end
        end
      end

      def self.by_query(search_query : String, limit : Int32 = 10) : Array(Models::Sound)
        q = SQL.by_name(search_query.gsub("'", "''"), limit)

        Array(Models::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Models::Sound.new(
              id: rs.read(Int32),
              user: Models::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
            )

            # Distances
            rs.read(Int32)
            rs.read(Int32)
          end
        end
      end
    end
  end
end
