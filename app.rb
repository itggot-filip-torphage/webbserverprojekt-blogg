require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'

get('/') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true

    result = db.execute("SELECT * FROM Posts")
    
    slim(:index, locals:{posts: result})
end