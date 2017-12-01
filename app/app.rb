ENV['RACK_ENV'] ||= 'development'
require 'sinatra/base'
require 'sinatra/flash'
require 'date'
require_relative 'dm_setup'

class Makersbnb < Sinatra::Base
  enable :sessions
  set :session_secret, 'cool'
  register Sinatra::Flash
  use Rack::MethodOverride

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end

    def save_to_database(this_model, relationship, instance)
      relationship << instance
      this_model.save
    end
  end

  get '/sign_up' do
    erb :sign_up
  end

  get '/' do
    erb :index
  end

  post '/' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/venue'
    else
      flash[:notice] = 'Incorrect email or password'
      redirect '/'
    end
  end

  get '/venue' do
    @venues = Venue.all
    erb :'venue/index'
  end

  get '/venue/new' do
    if current_user
      erb :'venue/new'
    else
      flash[:notice] = 'Please sign in to add venue'
      redirect '/'
    end
  end

  post '/venue' do
    venue = Venue.first_or_create(
      title: params[:title], address: params[:address], city: params[:city],
      price: params[:price], description: params[:description])
    picture = Picture.first_or_create(path: params[:picture])
    save_to_database(venue, venue.pictures, picture)
    save_to_database(current_user, current_user.venues, venue)
    redirect '/venue'
  end

  delete '/user' do
    session[:user_id] = nil
    flash[:notice] = 'Successfully Signed Out'
    redirect to '/'
  end

  post '/user' do
    user = User.create(name: params[:username], email: params[:email],
                       password: params[:password], password_confirmation: params[:password_confirmation])
    session[:user_id] = user.id
    if user.id.nil?
      flash[:errors] = user.errors.full_messages
      redirect '/sign_up'
    end
    redirect '/venue'
  end

  get '/view/:name' do
    @name = current_user.name
    @venue = Venue.all(title: params[:name]).last
    session[:title] = params[:name]
    session[:last_venue] = @venue.id
    erb :'venue/venue_page'
  end

  post '/view/:name' do
    venue = Venue.first(title: session[:title])
    @res = false

    if venue
      venue.reservations.each do |past_reservations|
        enddate = Date.parse(past_reservations.end_date.to_s)
        startdate = Date.parse(past_reservations.start_date.to_s)
        newstart = Date.parse(params[:startDate].to_s)
        newend = Date.parse(params[:endDate].to_s)
        if (enddate > newstart && newstart >= startdate) || (enddate >= newend && newend > startdate) || (newstart <= startdate && newend >= enddate)
          @res = true
        end
      end
    end

    if @res
      flash[:taken] = 'Dates Unavailable'
      redirect "/view/#{venue.title}"
    else
      reserve = Reservation.create(start_date: params[:startDate], end_date: params[:endDate])
      save_to_database(venue, venue.reservations, reserve)
      save_to_database(current_user, current_user.reservations, reserve)
      redirect '/reservations'
    end
  end

  get '/search/:city' do
    @venues = Venue.all(city: params[:city])
    erb :'venue/index'
  end

  post '/favorite/new' do
    venue = Venue.get(session[:last_venue])
    favorite = Favorite.create(user_id: current_user.id)
    save_to_database(favorite, favorite.venues, venue)
    save_to_database(current_user, current_user.favorites, favorite)
    redirect "/view/#{venue.title}"
  end

  get '/favorite' do
    favorites = Favorite.all
    all_user_with_favorites = favorites.user
    all_user_with_favorites.each do |user_with_fave|
      if current_user == user_with_fave
        fave = current_user.favorites
        @favorite_venues = fave.venues
      end
    end
    erb :'favorite/index'
  end

  get '/reservations' do
    reservations = Reservation.all
    all_users = reservations.user
    all_users.each do |user_with_reservation|
      if current_user == user_with_reservation
        reservations_of_the_user = current_user.reservations
        @venues = reservations_of_the_user.venue
      end
    end
    erb :'reservations/index'
  end
end
