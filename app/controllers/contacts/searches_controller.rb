class Contacts::SearchesController < ApplicationController
  def index
    if params[:query].present?
      @contacts = Contact.search_text(params[:query]).limit(10)
    else
      @contacts = Contact.order(created_at: :desc).limit(10)
    end

    if params[:kind].present? && Contact.kinds.keys.include?(params[:kind])
      @contacts = @contacts.where(kind: params[:kind])
    end

    render layout: false
  end
end
