require "./base"
require "./users"
require "../entities/sound"

module Soundmemes
  module Repositories
    class Sounds < Base
      module SQL
        extend self
        Tren.load("#{__DIR__}/tren/sounds.sql")
      end

      def create(telegram_user_id : Int32, title : String, tags : String | Nil, telegram_file_id : String)
        user_id = Users.new(db).by_telegram_id!(telegram_user_id).id

        data = {
          "user_id"          => user_id,
          "title"            => title,
          "tags"             => tags,
          "telegram_file_id" => telegram_file_id,
          "created_at"       => Time.now,
        }

        db.exec(builder.table("sounds").insert(data))
      end

      def recent(telegram_user_id : Int32, limit : Int32 = 10, search_query : String? = nil) : Array(Entities::Sound)
        q = if search_query
              SQL.recent(telegram_user_id, search_query.gsub("'", "''"), limit)
            else
              SQL.recent(telegram_user_id, limit)
            end

        Array(Entities::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Entities::Sound.new(
              id: rs.read(Int32),
              user: Entities::User.new(id: rs.read(Int32)),
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

      def favorites(telegram_user_id : Int32, limit : Int32 = 10) : Array(Entities::Sound)
        q = SQL.favorites(telegram_user_id, limit)

        Array(Entities::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Entities::Sound.new(
              id: rs.read(Int32),
              user: Entities::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
            )
          end
        end
      end

      def popular(limit : Int32 = 10) : Array(Entities::Sound)
        q = SQL.by_popularity(limit)

        Array(Entities::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Entities::Sound.new(
              id: rs.read(Int32),
              user: Entities::User.new(id: rs.read(Int32)),
              title: rs.read(String),
              telegram_file_id: rs.read(String),
            )
          end
        end
      end

      def by_query(search_query : String, limit : Int32 = 10) : Array(Entities::Sound)
        q = SQL.by_name(search_query.gsub("'", "''"), limit)

        Array(Entities::Sound).new.tap do |a|
          db.query_each(q) do |rs|
            a << Entities::Sound.new(
              id: rs.read(Int32),
              user: Entities::User.new(id: rs.read(Int32)),
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
