class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs
  def index
    # Precarichiamo sia le location che le partecipazioni con i contatti
    base_query = Job.includes(:location, participations: :contact)

    @jobs = case params[:filter]
    when "future"
              base_query.where("date >= ?", Date.current).order(date: :asc)
    when "unassigned"
              # Usiamo un left outer join per trovare i job senza fotografi
              base_query.left_outer_joins(:participations)
                .where(participations: { id: nil })
                .or(base_query.left_outer_joins(:participations).where.not(participations: { role: Participation::ROLES[:photographer] }))
                .group("jobs.id")
                .order(date: :desc)
    else
              base_query.recent
    end

    @pagy, @jobs = pagy(@jobs)
  end

  # GET /jobs/1
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
    assign_morph_params
  end

  # GET /jobs/1/edit
  def edit
    assign_morph_params
  end

  # POST /jobs
  def create
    @job = Job.new(job_params)

    if @job.save
      redirect_to jobs_path, notice: "Lavoro creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/1
  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Lavoro aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Lavoro eliminato definitivamente."
  end

  private
    def set_job
      @job = Job.includes(:location, participations: :contact).find(params[:id])
    end

    def assign_morph_params
      @job.location_id = params[:new_location_id] if params[:new_location_id].present?

      if params[:new_photographer_id].present?
        contact_id = params[:new_photographer_id].to_i
        unless @job.participations.any? { |p| p.role == Participation::ROLES[:photographer] && p.contact_id == contact_id }
          @job.participations.build(role: Participation::ROLES[:photographer], contact_id: contact_id)
        end
      end

      if params[:new_client_id].present?
        contact_id = params[:new_client_id].to_i
        unless @job.participations.any? { |p| p.role == Participation::ROLES[:client] && p.contact_id == contact_id }
          @job.participations.build(role: Participation::ROLES[:client], contact_id: contact_id)
        end
      end

      if params[:new_subject_id].present?
        contact_id = params[:new_subject_id].to_i
        unless @job.participations.any? { |p| p.role == Participation::ROLES[:subject] && p.contact_id == contact_id }
          @job.participations.build(role: Participation::ROLES[:subject], contact_id: contact_id)
        end
      end
    end

    def job_params
      params.require(:job).permit(
        :date, :start_at, :end_at, :description, :notes, :with_video, :location_id,

        # legacy
        :from_time, :to_time, :legacy_location,

        # contacts
        # photographer_ids: [],
        # client_ids: [],
        # subject_ids: []
        participations_attributes: [ :id, :contact_id, :role, :title, :_destroy ]
      )
    end
end
