DATABASE.results_as_hash = true

DATABASE.execute("CREATE TABLE IF NOT EXISTS parks (id INTEGER PRIMARY KEY,
 name TEXT, classification TEXT, nps_url TEXT, wiki_url TEXT, location TEXT, latitude TEXT, longitude TEXT)")