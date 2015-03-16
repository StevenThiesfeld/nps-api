def get_park_classifications
  Park.all.each do |park|
    begin
      nps_doc = Nokogiri::HTML(open(park.nps_url))
      park.classification = nps_doc.css("div.sub h3")[0].text.split("\n")[0].strip
    rescue
      park.classification = "none"
      park.save
    else
      park.save
    end
    sleep(2)
  end
  replace_blank_classifications
end

def replace_blank_classifications
  Park.all.each do |park|
    if park.classification == "" || park.classification == "No Classification"
      park.update(classification: "none")
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

def scrape_wikipedia_for_urls
  wiki_doc = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/List_of_areas_in_the_United_States_National_Park_System#National_Historic_Sites"))
  wiki_links = {}
  wiki_doc.css("tr td a").each do |link|
    wiki_links[link.text] = "http://en.wikipedia.org" + link["href"]
  end
  Park.all.each do |park|
    if wiki_links.keys.include?(park.name + " " + park.classification)
      park.update(wiki_url: wiki_links[park.name + " " + park.classification])
    end
  end
end

def get_lat_and_long
  Park.where(latitude: nil).each do |park|
    begin
    wiki_doc = Nokogiri::HTML(open(park.wiki_url))
    park.latitude = wiki_doc.css("span.latitude")[0].text
    park.longitude = wiki_doc.css("span.longitude")[0].text
    park.save
    rescue
    end
    sleep(2)
  end
end