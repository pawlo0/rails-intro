class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck(:rating)
    
    @sort = (params[:sort]) ? params[:sort] : session[:sort]
    
    if params[:ratings].nil?
        @selected_ratings = session[:ratings].nil? ? Hash[@all_ratings.map { |x| [x,x] } ] : session[:ratings] ; flash.keep ; redirect_to movies_path(:sort => @sort, :ratings => @selected_ratings)
    else
        @selected_ratings = params[:ratings]
    end
        
    @movies = Movie.where(:rating => @selected_ratings.keys).order(@sort)    
    
    session[:sort] = @sort
    session[:ratings] = @selected_ratings
    
    @hilite_title = 'hilite' if (@sort == 'title')
    @hilite_release = 'hilite' if (@sort == 'release_date')
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
