require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'

get('/index') do
    slim(:index)
end