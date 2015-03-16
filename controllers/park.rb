get "/parks" do
  parks = Park.all
  parks.to_json
end

get "/parks/:id" do
  park = Park.find(params[:id])
  binding.pry
  park.to_json
end 

