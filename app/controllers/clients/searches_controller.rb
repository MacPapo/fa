class Clients::SearchesController < ApplicationController
  def index
    @contacts = params[:query].present? ? Contact.search_text(params[:query]).limit(10) : Contact.none
    render partial: "clients/searches/results", locals: { contacts: @contacts }, layout: false
  end
end
