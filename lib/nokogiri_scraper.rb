module NokogiriScraper
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
  
  #get correct timestamp
  # t = Time.new
#   (t.to_f * 1000).to_i
  
  def scrape_park_alerts(park)
    park_abbr = park.nps_url.byteslice(19, 4)
    time = Time.new
    time = (time.to_f * 1000).to_i
    url = "http://www.nps.gov/mwr/renderhandlers/cs_chooser/rh_alert_chooser_json.cfm?siteCode=#{park_abbr}&ts=#{time}"
    alert_doc = Nokogiri::HTML(open(url))
    alert_doc.text
  end
  
  def scrape_description
    Park.all.each do |park|
      nps_doc = Nokogiri::HTML(open(park.nps_url))
      binding.pry
    end
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
  
  def scrape_location_from_nps
    Park.where(location: nil).each do |park|
      begin
      nps_doc = Nokogiri::HTML(open(park.nps_url))
      park.update(location: nps_doc.css("span.location")[0].text.strip)
      rescue
        park.update(location: "issue")
      end
      sleep(2)
    end
  end
  
  def set_location_to_state_abbr
    states = {
          "Alabama" => "AL",
          "Alaska" => "AK",
          "Arizona" => "AZ",
          "Arkansas" => "AR",
          "California" => "CA",
          "Colorado" => "CO",
          "Connecticut" => "CT",
          "Delaware" => "DE",
          "District of Columbia" => "DC",
          "Florida" => "FL",
          "Georgia" => "GA",
          "Hawai'i" => "HI",
          "Idaho" => "ID",
          "Illinois" => "IL",
          "Indiana" => "IN",
          "Iowa" => "IA",
          "Kansas" => "KS",
          "Kentucky" => "KY",
          "Louisiana" => "LA",
          "Maine" => "ME",
          "Maryland" => "MD",
          "Massachusetts" => "MA",
          "Michigan" => "MI",
          "Minnesota" => "MN",
          "Mississippi" => "MS",
          "Missouri" => "MO",
          "Montana" => "MT",
          "Nebraska" => "NE",
          "Nevada" => "NV",
          "New Hampshire" => "NH",
          "New Jersey" => "NJ",
          "New Mexico" => "NM",
          "New York" => "NY",
          "North Carolina" => "NC",
          "North Dakota" => "ND",
          "Ohio" => "OH",
          "Oklahoma" => "OK",
          "Oregon" => "OR",
          "Pennsylvania" => "PA",
          "Rhode Island" => "RI",
          "South Carolina" => "SC",
          "South Dakota" => "SD",
          "Tennessee" => "TN",
          "Texas" => "TX",
          "Utah" => "UT",
          "Vermont" => "VT",
          "Virginia" => "VA",
          "Washington" => "WA",
          "West Virginia" => "WV",
          "Wisconsin" => "WI",
          "Wyoming" => "WY"
        }
        states.each do |name, abbr|
          Park.where(location: name).each do |park|
            park.update(location: abbr)
          end
        end
      end
  
end# module end

