get "/parks" do
  parks = Park.all
  parks.to_json
end

get "/parks/:id" do
  if park = Park.find_by(id: params[:id])
    response = {}
    response[:parkinfo] = park.to_json
    response[:alerts] = scrape_park_alerts(park)
    response.to_json
  else
    "No Results Found"
  end
end 

get "/parks/state/:state" do
  parks = Park.where("location like ?", "%" + params[:state] + "%")
  parks.to_json
end

get "/parks/classification/:query" do
  parks = Park.where("classification like ?", "%" + params[:query] + "%")
  response = {}
  parks.each do |park|
    response[park.name] = {}
    response[park.name][:parkinfo] = park.to_json
    response[park.name][:alerts] = scrape_park_alerts(park)
    sleep(1)
  end
  response.to_json
end

get "/parks/name/:query" do
  parks = Park.where("name like ?", "%" + params[:query] + "%")
  response = {}
  parks.each do |park|
    response[park.name] = {}
    response[park.name][:parkinfo] = park.to_json
    response[park.name][:alerts] = scrape_park_alerts(park)
  end
  response.to_json
end

