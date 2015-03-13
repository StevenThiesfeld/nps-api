def set_irregular_wiki_urls
  links = []
  Park.where(wiki_url: nil).each do |park|
    google_doc = Nokogiri::HTML(open("https://www.google.com/search?q=" + set_google_query(park)))
    google_results = google_doc.css("h3.r a")
    google_results.each do |link|
      if link.text.include?("Wikipedia")
        links << link["href"]
      end
    end
  end
end

def set_google_query(park)
  if park.classification != "No Official Classification"
    query = (park.name + " " + park.classification).gsub(" ", "+")
  else
    query = park.name.gsub(" ", "+")
  end
  query
end
