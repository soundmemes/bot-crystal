require "db"
require "pg"

puts "Database URL: " + ENV["DATABASE_URL"]

class DBWrapper
  @@db : DB::Database = DB.open(ENV["DATABASE_URL"] || raise "No DATABASE_URL is set")

  def self.db
    @@db
  end
end

def db
  DBWrapper.db
end
