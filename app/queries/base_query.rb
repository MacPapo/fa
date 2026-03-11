class BaseQuery
  attr_reader :relation, :params

  def initialize(relation, params = {})
    @relation = relation
    @params = params
  end

  def resolve
    scope = relation
    scope = apply_search(scope)
    scope = apply_filter(scope)
    apply_sort(scope)
  end

  private
    def apply_search(scope)
      clean_query = params[:query].to_s.strip
      return scope if clean_query.blank?

      scope.search_text(clean_query)
    end

    def apply_filter(scope)
      scope
    end

    def apply_sort(scope)
      if params[:query].to_s.strip.present? && params[:sort].blank?
        return scope
      end

      case params[:sort]
      when "alpha"
        sort_alpha(scope)
      else
        sort_recent(scope)
      end
    end

    def sort_recent(scope)
      scope.reorder(created_at: :desc)
    end

    def sort_alpha(scope)
      raise NotImplementedError, "Le sottoclassi devono implementare #sort_alpha"
    end
end
