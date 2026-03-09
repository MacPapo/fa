class SearchesController < ApplicationController
  layout false

  def index
    @query = params[:query].to_s.strip

    if @query.length >= 2
      @contacts  = Contact.search_text(@query).limit(5)
      @locations = Location.search_text(@query).limit(5)
      @jobs      = Job.global_search(@query).limit(5)
    else
      @contacts = @locations = @jobs = []
    end
  end
end
