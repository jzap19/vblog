require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'byebug'

# overall good job jose. There are some pieces to this that are a bit weird.
# like if i'm not logged in I shouldn't see the "Create a new Blog" link.
# The dashboard page is only visible after login and it doesn't really serve it's purpose.
# let me know if you want to talk about these and dive deeper into what I mean.

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
  # jose should probably check if the user_id is present before creating the blog post.
  Blog.create(name: params[:name], description: params[:description], user_id: session[:user_id])
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?
  redirect '/'
end

get '/blog/edit/:id' do
  user_id = session[:user_id]
  return redirect '/' if user_id.nil?

  # should check the user_id before finding the blog
  @blog = Blog.find(params[:id])
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
