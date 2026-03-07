class Subjects::SearchesController < ApplicationController
  def index
    @contacts = params[:query].present? ? Contact.person.search_text(params[:query]).limit(10) : Contact.none
    render partial: "subjects/searches/results", locals: { contacts: @contacts }, layout: false
  end
end
