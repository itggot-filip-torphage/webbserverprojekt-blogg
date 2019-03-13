require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'

enable :sessions


post('/color') do
    session['color'] = params['Color']
    redirect("/profile/#{params['id']}")
end

get('/') do
    session['color'] == 'lightgray'
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT * FROM Posts")
    
    slim(:index, locals:{posts: result, session: session})
end

get('/login') do
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT id, password FROM Users WHERE username=?", [params["Username"]])

    if result.length == 0
        redirect('/login')
    end

    if BCrypt::Password.new(result[0]["password"]) == params["Password"]
        session["user_id"] = result[0]["id"]
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
    
    session["user_id"] = params["Username"]
    redirect('/')        
end

get('/profile/:id') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true

    posts = db.execute("SELECT * FROM Posts WHERE user_id=?", [params["id"]])
    user_data = db.execute("SELECT * FROM Users WHERE id=?", [params["id"]])

    slim(:profile, locals:{posts: posts, user: user_data[0], session: session})
end

get('/profile/:id/edit') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT * FROM Users WHERE id=?", [params["id"]])
    
    slim(:profile_edit, locals:{user: result[0]})
end

post('/profile/:id/edit') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    hash_password = BCrypt::Password.create(params["Password"])
    
    result = db.execute("REPLACE INTO Users (id, username, password, pic) VALUES (?, ?, ?, ?)",
    [params["id"], params["Username"], hash_password, params["Pic"]]
    )
    
    redirect("/profile/#{params['id']}")
end

get('/new_post') do
    slim(:new_post)
end

post('/new_post') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true

    user_name = db.execute("SELECT username FROM Users WHERE id=?", [session["user_id"]])
    
    if params["Pic"].length == 0
        pic = nil
    else
        pic = params["Pic"]
    end
    db.execute("INSERT INTO Posts (content, user_id, author, pic) VALUES (?, ?, ?, ?)",
        [params["Content"], session["user_id"], params["Author"], pic]
    )
    
    redirect('/')
end