require "db"
require "pg"

class Services::DB
  # DB::Database is a pool, so one instance is enough for the whole program
  class_getter instance : ::DB::Database = ::DB.open(ENV["DATABASE_URL"] || raise "No DATABASE_URL is set")
end

# Shortcut for convenience
def db
  Services::DB.instance
end

at_exit { Services::DB.instance.close }
