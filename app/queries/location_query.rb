class LocationQuery < BaseQuery
  def initialize(relation = Location.all, params = {})
    super(relation, params)
  end

  private
    def sort_alpha(scope)
      scope.reorder(name: :asc, district: :asc)
    end
end
