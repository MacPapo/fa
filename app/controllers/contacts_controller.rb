class ContactsController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy ]

  def index
    @contacts = Contact.order(last_name: :asc, first_name: :asc, company_name: :asc)

    if params[:filter] == "person"
      @contacts = @contacts.person
    elsif params[:filter] == "company"
      @contacts = @contacts.company
    end

    @pagy, @contacts = pagy(@contacts)
  end

  def show
    @participations = @contact.participations
                              .includes(job: :location)
                              .order("jobs.date DESC")
  end

  def new
    @contact = Contact.new(kind: params[:kind].presence || "person")
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      respond_to do |format|
        if params[:modal_id].present?
          format.turbo_stream
        else
          format.html { redirect_to @contact, notice: "Contatto aggiunto alla rubrica." }
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "Scheda contatto aggiornata."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: "Contatto eliminato.", status: :see_other
  end

  private
    def set_contact
      @contact = Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(
        :kind,
        :first_name,
        :last_name,
        :company_name,
        :phone,
        :email,
        :vat_number,
        :tax_id
      )
    end
end
