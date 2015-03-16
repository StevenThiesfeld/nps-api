# # DATABASE.execute("CREATE TABLE IF NOT EXISTS parks (id INTEGER PRIMARY KEY,
#  name TEXT, classification TEXT, nps_url TEXT, wiki_url TEXT, location TEXT,
#   latitude TEXT, longitude TEXT)")

unless ActiveRecord::Base.connection.table_exists?(:parks)
  ActiveRecord::Base.connection.create_table :parks do |t|
    t.text :name
    t.text :classification
    t.text :nps_url
    t.text :wiki_url
    t.text :location
    t.text :latitude
    t.text :longitude
  end
end