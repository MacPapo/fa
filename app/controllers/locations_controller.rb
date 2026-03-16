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
    render layout: "modal"
  end

  def create
    @location = Location.new(location_params)

    unless @location.save
      render :new, layout: "modal", status: :unprocessable_entity
    end
  end

  def edit
    render layout: "modal"
  end

  def update
    unless @location.update(location_params)
      render :edit, layout: "modal", status: :unprocessable_entity
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
