require "./base"

module Soundmemes
  module Repositories
    class User < Base
      include DB

      # Return true if successfully created a new user, otherwise (if the user already exists) return false
      #
      def create?(telegram_id : Int32) : Bool
        !!(unless db.query_one?(builder.table("users").where("telegram_id", telegram_id).select("id").get, as: {Int32 | Nil})
          data = {
            "telegram_id" => telegram_id,
            "created_at"  => Time.now,
          }
          db.exec(builder.table("users").insert(data))
          true
        end)
      end

      def by_telegram_id(telegram_id : Int32) : Models::User | Nil
        id = db.query_one(builder.table("users").where("telegram_id", telegram_id).select("id").get, as: {Int32})
        id ? Models::User.new(id: id, telegram_id: telegram_id) : nil
      end

      # Return a user or raise a error if not found
      def by_telegram_id!(telegram_id : Int32) : Models::User
        by_telegram_id(telegram_id) || raise "User not found with telegram_id #{telegram_id}!"
      end
    end
  end
end
