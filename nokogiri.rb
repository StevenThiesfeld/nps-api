require 'open-uri'
doc = Nokogiri::HTML(open("http://www.nps.com/"))
binding.pry