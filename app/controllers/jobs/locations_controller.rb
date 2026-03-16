class Jobs::LocationsController < ApplicationController
  def new
    @location = Location.new(name: params[:name])
    render "locations/new", layout: "modal", locals: { submit_url: jobs_locations_path }
  end

  def create
    @location = Location.new(location_params)

    unless @location.save
      render "locations/new", layout: "modal", locals: { submit_url: jobs_locations_path }, status: :unprocessable_entity
    end
  end

  private
    def location_params
      params.require(:location).permit(:name, :district)
    end
end
