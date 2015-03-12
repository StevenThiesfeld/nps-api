require 'open-uri'



def get_park_classifications
  Park.all.each do |park|
    begin
      nps_doc = Nokogiri::HTML(open(park.nps_url))
      park.classification = nps_doc.css("div.sub h3")[0].text.split("\n")[0].strip
    rescue
      park.classification = "No Classification"
      park.save
    else
      park.save
    end
  end
end

def create_park_entries
  nps_doc = Nokogiri::HTML(open("http://www.nps.gov/PWR/customcf/apps/park-search/panelThree.cfm?name=all"))
  nps_doc.css("p").each do |p|
    park = Park.new
    park.name = p.children.text.strip
    park.nps_url = "http://www.nps.gov" + p["onclick"].byteslice(12, 6) + "index.htm"
    park.save
  end
end






#doc.css("p")[0]["onclick"]#targets value of onclick "selectPark('/abli/');return false;" need to parse this out, common pattern?

#url.byteslice(11, 7) gets park url
# wiki_doc = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/" + park.name.gsub(" ", "_")))
# park.location = wiki_doc.css("tr.locality a")[0].text
# park.coordinates = wiki_doc.css("span.latitude")[0].text + " " + wiki_doc.css("span.longitude")[0].text
# park_objects << park

#lat+long wiki_doc.css("span.latitude")[0].text +" " + wiki_doc.css("span.longitude")[0].text