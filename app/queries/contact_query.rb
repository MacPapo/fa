class ContactQuery < BaseQuery
  def initialize(relation = Contact.all, params = {})
    super(relation, params)
  end

  private
    def apply_filter(scope)
      case params[:filter]
      when "person"  then scope.person
      when "company" then scope.company
      else scope
      end
    end

    def sort_alpha(scope)
      scope.reorder(last_name: :asc, first_name: :asc, company_name: :asc)
    end
end
