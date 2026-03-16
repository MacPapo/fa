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

    if @location.save
      respond_to { |format| format.turbo_stream }
    else
      render :new, layout: "modal", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location aggiornata." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
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
