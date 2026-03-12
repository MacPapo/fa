class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  def index
    @total_locations = Location.count
    @locations = LocationQuery.new(Location.all, params).resolve

    @pagy, @locations = pagy(@locations)
  end

  def show
    @total_location_jobs = @location.jobs.count
    @jobs = JobQuery.new(@location.jobs, params).resolve

    @pagy, @jobs = pagy(@jobs)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.turbo_stream
        format.html { redirect_to @location, notice: "Location creata." }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location aggiornata."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to locations_path, notice: "Location eliminata.", status: :see_other
  end

  private
    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.require(:location).permit(:name, :district)
    end
end
