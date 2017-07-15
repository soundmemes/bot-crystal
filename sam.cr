require "sam"
require "micrate"
require "pg"
require "dotenv"
require "colorize"

logger = Logger.new(STDOUT)

Sam.task "environment" do |t, args|
  ENV["APP_ENV"] ||= "development"
  Dotenv.load ".env.#{ENV["APP_ENV"]}"
end

def checkmark
  "✅ ".colorize(:green).mode(:bold)
end

Sam.namespace "db" do
  namespace "migrate" do
    task "prepare", ["environment"] do
      Micrate::DB.connection_url = ENV["DATABASE_URL"] || raise "No DATABASE_URL is set"
    end

    desc "Migrate DB up one step up"
    task "up", ["prepare"] do |t, args|
      DB.open ENV["DATABASE_URL"] do |db|
        logger.info "Migrating up from version #{Micrate.dbversion(db).colorize.mode(:bold)}..."
        Micrate.up(db)
        logger.info "#{checkmark} Migrated to version #{Micrate.dbversion(db).colorize.mode(:bold)}"
      end
    end

    desc "Migrate DB one step down"
    task "down", ["prepare"] do |t, args|
      DB.open ENV["DATABASE_URL"] do |db|
        logger.info "Migrating down from version #{Micrate.dbversion(db).colorize.mode(:bold)}..."
        Micrate.down(db)
        logger.info "#{checkmark} Migrated to version #{Micrate.dbversion(db).colorize.mode(:bold)}"
      end
    end

    desc "Re-migrate DB from scratch"
    task "redo", ["prepare"] do |t, args|
      DB.open ENV["DATABASE_URL"] do |db|
        logger.info "Re-migrating from version #{Micrate.dbversion(db).colorize.mode(:bold)}..."
        Micrate.redo(db)
        logger.info "#{checkmark} Re-migrated to version #{Micrate.dbversion(db).colorize.mode(:bold)}"
      end
    end

    desc "Create a new migration"
    task "create", ["prepare"] do |t, args|
      logger.info "Creating a new migration..."
      path = Micrate.create(args["name"], "./db/migrations", Time.now)
      logger.info "#{checkmark} Created migration #{path.colorize.mode(:bold)}"
    end
  end
end

Sam.help
