require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'sinatra'
require 'nokogiri'
# require 'activesupport'
require 'sinatra/activerecord'
require 'json'
require 'pg'
require 'open-uri'

configure :development do
  require 'sqlite3'
  set :database, {adapter: "sqlite3", database: "parks_database.db"}
end

configure :production do
 db = URI.parse(ENV['DATABASE_URL'])
 ActiveRecord::Base.establish_connection(
 :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
 :host => db.host,
 :username => db.user,
 :password => db.password,
 :database => db.path[1..-1],
 :encoding => 'utf8'
 )
end

require_relative 'database/db_setup'
require_relative 'models/park'
require_relative "lib/url_translator"
require_relative "lib/nokogiri_scraper"
require_relative "controllers/park"
include NokogiriScraper
binding.pry