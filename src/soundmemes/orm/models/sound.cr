require "tren"
require "../repo"
require "./user"

module Soundmemes
  class Sound < Crecto::Model
    schema "sounds" do
      belongs_to :user, User
      field :title, String
      field :tags, String
      field :telegram_file_id, String
      field :popularity, Float32
      field :posts_count, PkeyValue, virtual: true
      has_many :posts, SoundPost
    end

    validate_required [:user_id, :title, :telegram_file_id]

    def self.recent(user : User, limit : Int32, search_query : String? = nil)
      query = ""
      if search_query
        query = SQL.recent(user.telegram_id, limit, search_query.gsub("'", "''"))
      else
        query = SQL.recent(user.telegram_id, limit)
      end
      Repo.query(self, query)
    end

    def self.popular(limit : Int32, offset : Int32 = 0)
      Repo.all(self, Query.order_by("COALESCE(popularity, 0) DESC").limit(limit).offset(offset)).as(Array(self))
    end

    def self.favorites(user : User, limit : Int32, offset : Int32 = 0)
      query = SQL.favorites(user.telegram_id, limit, offset)
      Repo.query(self, query)
    end

    def self.search_by_query(query name : String, limit : Int32)
      query = SQL.by_name(name.gsub("'", "''"), limit)
      Repo.query(self, query)
    end

    module SQL
      extend self
      Tren.load("#{__DIR__}/sql/sounds/*.sql")
    end
  end
end
