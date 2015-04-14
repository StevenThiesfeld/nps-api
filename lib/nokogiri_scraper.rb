 # Public: Various methods using nokogiri to scrape data from the National Parks Service website.
 
module NokogiriScraper
  
  # Seeds the database with a list of park records and establishes a link to the nps webpage for a given park. 
  def create_park_entries
    nps_doc = Nokogiri::HTML(open("http://www.nps.gov/PWR/customcf/apps/park-search/panelThree.cfm?name=all"))
    nps_doc.css("p").each do |p|
      park = Park.new
      park.name = p.children.text.strip
      park.nps_url = "http://www.nps.gov" + p["onclick"].byteslice(12, 6) + "index.htm"
      park.save
    end
  end
  
  # scrapes the classification for all parks and replaces black fields with "none".
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
  
  # uses Watir and phantomjs to scrape any active alerts from a webpage.
  def scrape_park_alerts(park)
    b = Watir::Browser.new(:phantomjs)
    b.goto park.nps_url
    doc = Nokogiri::HTML(b.html)
    b.close
    alert = {}
    alert["title"] = doc.css("div#alert-message h4").text
    alert["body"] = doc.css("div#alert-message p").text
    alert
  end
  
  # scrapes the description content for all parks from nps.gov.
  def scrape_description
    Park.all.each do |park|
      begin
        nps_doc = Nokogiri::HTML(open(park.nps_url))
        park.description = nps_doc.css("div.cs_control p")[0].text
        park.description_title = nps_doc.css("div.cs_control h1.page-title")[0].text
        park.save
      rescue
      end
      sleep(2)
    end
  end
  
  # replaces any blank classification fields with "none".
  def replace_blank_classifications
    Park.all.each do |park|
      if park.classification == ""
        park.update(classification: "none")
      end
    end
  end
 
  # Scrapes wikipedia's list of national parks for pages matching names from nps.gov and saves wiki_url for all parks found.
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
  
  # Scrapes all park wikipedia pages for latitude and longitude where applicable.  lat and long fields that weren't found are left nil. 
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
  
  # scrapes the location (by state) for each park from nps.gov  Some sites span multiple states.
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
  
  # constructs a google search from park name and classification and scrapes results for a park's wikipedia url
  def set_irregular_wiki_urls
    Park.where(wiki_url: nil).each do |park|
      google_doc = Nokogiri::HTML(open("https://www.google.com/search?q=" + set_google_query(park)))
      google_results = google_doc.css("h3.r a")
      google_results.each do |link|
        if link.text.include?("Wikipedia")
          park.update(wiki_url: link["href"].string_between_markers("?q=", "&sa"))
        end
      end
      sleep(2)
    end
  end

  # puts together the query based on presence of classification
  def set_google_query(park)
    if park.classification != "none"
      query = (park.name + " " + park.classification).gsub(" ", "+")
    else
      query = park.name.gsub(" ", "+")
    end
    query
  end

  # custom string method for extracting a sub-string between 2 given pattern markers.  Used to extract the wikipedia url from google results.
  class String
    def string_between_markers marker1, marker2
      self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
  end
  
  # replaces any full state names to a more manageable abbreviation.
  # only needed for parks with a single state as location. 
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

