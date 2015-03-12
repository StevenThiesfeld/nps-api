require 'open-uri'
doc = Nokogiri::HTML(open("http://www.nps.gov/agfo/planyourvisit/hours.htm"))
