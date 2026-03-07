class PhotographersController < ApplicationController
  def create
    @photographer = Contact.new(photographer_params)

    if @photographer.save
      if params[:return_to].present?
        redirect_to build_morph_url(params[:return_to], :new_photographer_id, @photographer.id)
      else
        redirect_to root_path, notice: "Fotografo creato."
      end
    else
      redirect_to params[:return_to] || root_path, alert: "Errore nella creazione."
    end
  end

  private
    def photographer_params
      params.require(:contact).permit(:first_name, :last_name, :phone, :kind)
    end
end
