class ClientsController < ApplicationController
  def create
    @client = Contact.new(client_params)

    if @client.save
      if params[:return_to].present?
        redirect_to build_morph_url(params[:return_to], :new_client_id, @client.id)
      else
        redirect_to root_path, notice: "Cliente creato."
      end
    else
      # In produzione vorrai gestire meglio gli errori, magari con un alert Turbo, ma per ora fallback pulito
      redirect_to params[:return_to] || root_path, alert: "Errore: #{@client.errors.full_messages.join(', ')}"
    end
  end

  private
    def client_params
      params.require(:contact).permit(:kind, :company_name, :first_name, :last_name, :vat_number, :email, :phone)
    end
end
