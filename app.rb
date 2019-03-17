require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'
require 'securerandom'

enable :sessions


def save_pic(params)
    picture = params["Pic"]
    if picture.length == 0
        return
    end
    temp_file = picture["tempfile"]
    path = File.path(temp_file)
    
    new_file_name = SecureRandom.uuid
    FileUtils.copy(path, "./public/uploads/#{new_file_name}")

    return new_file_name
end

post('/color') do
    session['color'] = params['Color']
    redirect("/profile/#{params['id']}")
end

get('/') do
    session['color'] == 'lightgray'
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    @posts = db.execute("SELECT * FROM Posts")
    @session = session
    
    slim(:index)
end

get('/login') do
    @session = session
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
    @session = session
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
    
    user_id = db.execute("SELECT id FROM Users WHERE username=?", [params["Username"]])
    
    session["user_id"] = user_id
    redirect('/')        
end

get('/profile/:id') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    @posts = db.execute("SELECT * FROM Posts WHERE user_id=?", [params["id"]])
    @user = db.execute("SELECT * FROM Users WHERE id=?", [params["id"]])[0]
    @session = session
    
    slim(:profile)
end

get('/profile/:id/edit') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    @user = db.execute("SELECT * FROM Users WHERE id=?", [params["id"]])[0]
    @session = session
    
    slim(:profile_edit)
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
    @session = session
    slim(:new_post)
end

post('/new_post') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    file_name = save_pic(params)
    if params["Pic"].length == 0
        pic = nil
    else
        pic = "#{file_name}"
    end
    db.execute("INSERT INTO Posts (content, user_id, author, pic) VALUES (?, ?, ?, ?)",
    [params["Content"], session["user_id"], params["Author"], pic]
    )
    
    redirect('/')
end

get('/post/:id/edit') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    @post = db.execute("SELECT * FROM Posts WHERE id=?", [params["id"]]).first
    @session = session
    
    slim(:post_edit)
end

post('/post/:id/edit') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    file_name = save_pic(params)
    if params["Pic"].length == 0
        pic = nil
    else
        pic = "#{file_name}"
    end
    
    db.execute("REPLACE INTO Posts (id, content, user_id, author, pic) VALUES (?, ?, ?, ?, ?)",
    [params["id"], params["Content"], session["user_id"], params["Author"], pic]
    )
    
    redirect('/')
end

post('/post/:id/delete') do
    db = SQLite3::Database.new("db/blog.db")
    db.results_as_hash = true
    
    db.execute("DELETE FROM Posts WHERE id=?", [params['id']])
    
    redirect('/')
end

post('/logout') do 
    session.clear
    redirect(back)
end