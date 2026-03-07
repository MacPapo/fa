class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  def index
    @locations = Location.order(:name)
  end

  def show
    # Carichiamo i lavori associati a questa location
    @jobs = Job.where(location_id: @location.id).order(date: :desc)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      respond_to do |format|
        if params[:modal_id].present?
          format.turbo_stream
        else
          format.html { redirect_to @location, notice: "Location creata." }
        end
      end
    else
      render :new, status: :unprocessable_entity
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
      params.require(:location).permit(:name, :address, :city, :zip) # Aggiungi i campi reali del tuo DB
    end
end
