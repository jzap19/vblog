require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'byebug'

set :session_secret, ENV['SUPER_API_SECRET']
enable :sessions

get '/' do
  @blogs = Blog.all
  erb :index
end

get ('/index') do
  @user_logged_out = (session[:user_id] == nil)
  @blogs = Blog.all
  erb :index
end

get('/logout') do
  user_id = session[:user_id]
  session.clear
  erb(:logout)
end

get('/signup') do
  erb :signup
end
post('/') do
  existing_user = User.find_by(email: params[:email])
  return redirect '/login' unless existing_user.nil?
  user = User.create(
    first_name: params[:f_name],
    last_name: params[:l_name],
    email: params[:email],
    birthday: params[:birthday],
    password: params[:password]
  )
  session[:user_id] = user.id
  redirect '/dashboard'
end

get('/login') do
  erb :login
end

post('/login') do
  # params = {user_email: , password:}

  user = User.find_by(email: params[:user_email])
  return redirect '/login' if user.nil?

  return redirect '/login' unless user.password == params[:password]

  session[:user_id] = user.id
  redirect '/dashboard'
end

get('/dashboard') do
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?

  @user = User.find(user_id)

  erb :dashboard
end
# post('/dashboard') do
#   user_id = session[:user_id]
#   if user_id.nil?
#     return redirect '/'
#   end
# redirect '/index'
# end
get '/blog/new' do
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  erb :new
end
post('/logout') do
  user_id = session[:user_id]
  return redirect '/index' if user_id.nil?
  redirect '/index'
end
post '/blog/create' do
  Blog.create(name: params[:name], description: params[:description], user_id: session[:user_id])
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  redirect '/'
end

get '/blog/edit/:id' do
  @blog = Blog.find(params[:id])
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  erb :edit
end

post '/blog/update/:id' do
  blog = Blog.find(params[:id])
  blog.update(name: params[:name], description: params[:description])
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  redirect '/'
end

get '/blog/delete/:id' do
  blog = Blog.find(params[:id])
  blog.destroy
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  redirect '/'
end
