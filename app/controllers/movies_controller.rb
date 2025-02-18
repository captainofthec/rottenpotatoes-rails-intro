class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    
  end

  helper_method :sort_this
  def sort_this(col)
    if params[:sort] == col
      'hilite'
    end 

  end 

  def index
    
    if params["ratings"].nil? or params[:sort].nil?
      params[:sort] ||= session[:sort] || ""
      
      params["ratings"] ||= session["ratings"] || Hash[all_ratings.collect{|rating| [rating,"1"]} ]
      
      flash.keep
      redirect_to movies_path(:sort => params[:sort], "ratings" => params["ratings"])
      return
    end
    
    @all_ratings = all_ratings
    
    @movies = Movie.order(params[:sort])
    
    
    
    if !(params["ratings"].nil?)
      @movies = @movies.where(:rating => params["ratings"].map{|k,v| k if v == "1"}.to_a)
    end
    
    session["ratings"] = params["ratings"]
    session[:sort] = params[:sort]
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end
  
  def all_ratings 
    Movie.select(:rating).map(&:rating).uniq
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
