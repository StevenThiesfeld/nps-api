require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
DATABASE = SQLite3::Database.new("parks_database.db")
require_relative 'database/db_setup'
set :database, {adapter: "sqlite3", database: "parks_database.db"}
require_relative 'models/park'
require_relative "lib/url_translator"
require_relative "lib/scraper"
require 'open-uri'
binding.pry
