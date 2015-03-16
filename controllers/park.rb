get "/parks" do
  parks = Park.all
  parks.to_json
end

get "/parks/:id" do
  park = Park.find(params[:id])
  response = {}
  response[:parkinfo] = park.to_json
  response[:alerts] = scrape_park_alerts(park)
  response.to_json
end 

get "/parks/state/:state" do
  parks = Park.where("location like ?", "%" + params[:state] + "%")
  parks.to_json
end

