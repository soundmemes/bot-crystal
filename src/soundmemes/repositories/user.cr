require "./base"

module Soundmemes
  module Repositories
    class User < Base
      # Return true if successfully created a new user, otherwise (if the user already exists) return false
      #
      def self.create?(telegram_id : Int32) : Bool
        DB.open ENV["DATABASE_URL"] do |db|
          !!(unless db.query_one?(builder.table("users").where("telegram_id", telegram_id).select("id").get, as: {Int32 | Nil})
            data = {
              "telegram_id" => telegram_id,
              "created_at"  => Time.now,
            }
            db.exec(builder.table("users").insert(data))
            true
          end)
        end
      end

      def self.by_telegram_id(telegram_id : Int32) : Models::User | Nil
        id = db.query_one(builder.table("users").where("telegram_id", telegram_id).select("id").get, as: {Int32})
        id ? Models::User.new(id: id, telegram_id: telegram_id) : nil
      end

      # Return a user or raise a error if not found
      def self.by_telegram_id!(telegram_id : Int32) : Models::User
        by_telegram_id(telegram_id) || raise "User not found with telegram_id #{telegram_id}!"
      end
    end
  end
end
