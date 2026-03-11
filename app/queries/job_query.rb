class JobQuery < BaseQuery
  def initialize(relation = Job.all, params = {})
    super(relation, params)
  end

  private
    def apply_filter(scope)
      scope = filter_by_period(scope)
      scope = filter_by_video(scope)
      scope
    end

    def filter_by_period(scope)
      case params[:period]
      when "upcoming"  then scope.where("date >= ?", Date.current)
      when "past"      then scope.where("date < ?", Date.current)
      when "this_year" then scope.where(date: Date.current.beginning_of_year..Date.current.end_of_year)
      else scope
      end
    end

    def filter_by_video(scope)
      case params[:video]
      when "true"  then scope.where(with_video: true)
      when "false" then scope.where(with_video: false)
      else scope
      end
    end

    def apply_sort(scope)
      if params[:query].to_s.strip.present? && params[:sort].blank?
        return scope
      end

      case params[:sort]
      when "date_asc"
        scope.reorder(date: :asc)
      when "date_desc"
        scope.reorder(date: :desc)
      when "recent_creation"
        scope.reorder(created_at: :desc)
      else
        if params[:period] == "upcoming"
          scope.reorder(date: :asc)
        else
          scope.reorder(date: :desc)
        end
      end
    end
end
