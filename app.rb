require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'

enable :sessions

get('/') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT * FROM Posts")
    
    slim(:index, locals:{posts: result})
end

get('/login') do
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT id, password FROM Users WHERE username=?", [params["Username"]])

    if BCrypt::Password.new(result[0]["password"]) == params["Password"]
        session["user"] = params["Username"]
        redirect('/')        
    else
        redirect('/login')
    end
end

get('/signup') do
    slim(:signup)
end

post('/signup') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT username FROM Users WHERE username=?", [params["Username"]])

    if result.length != 0
        redirect('/signup')
    end

    hash_password = BCrypt::Password.create(params["Password"])

    db.execute("INSERT INTO Users (username, password, pic) VALUES (?, ?, '7d1c0004-073e-4fce-a1b5-03c05b936c1f.jpg')", [params["Username"], hash_password])
    
    session["user"] = params["Username"]
    redirect('/')        
end