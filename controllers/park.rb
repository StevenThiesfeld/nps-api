get "/parks/all" do
  parks = Park.all
  parks.to_json
end 