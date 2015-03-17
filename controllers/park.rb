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

get "/parks/classification/:classification" do
end

get "/parks/name/:query" do
end

